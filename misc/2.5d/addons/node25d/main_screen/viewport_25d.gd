## 编辑器 2.5D 视口控制 —— 提供视角切换、缩放、平移和 Gizmo 管理。
##
## 作为编辑器主面板的核心控制组件，管理 SubViewport 的渲染和交互。
## 功能包括:
## - 视角模式切换（通过按钮组）
## - 鼠标滚轮缩放
## - 鼠标中键平移
## - 选中 Node25D 节点的 Gizmo 创建/更新/删除
@tool
extends Control


## 当前缩放等级（指数级，基数为 2 的 13 次方根）
var zoom_level: int = 0
## 是否正在平移
var is_panning: bool  = false
## 平移起始位置
var pan_center: Vector2
## 视口中心位置
var viewport_center: Vector2
## 当前视角模式索引
var view_mode_index: int = 0

## 编辑器接口引用（在 node25d_plugin.gd 中设置）
var editor_interface: EditorInterface
## Gizmo 是否正在拖动
var moving = false

@onready var viewport_2d = $Viewport2D
@onready var viewport_overlay = $ViewportOverlay
@onready var view_mode_button_group: ButtonGroup = $"../TopBar/ViewModeButtons/45Degree".button_group
@onready var zoom_label: Label = $"../TopBar/Zoom/ZoomPercent"
@onready var gizmo_25d_scene = preload("res://addons/node25d/main_screen/gizmo_25d.tscn")


func _ready() -> void:
	# 等待两帧确保场景完全加载
	for i in 2:
		await get_tree().process_frame

	var edited_scene_root = get_tree().edited_scene_root
	if not edited_scene_root:
		# Godot 尚未完成加载，重新启用插件以触发重新初始化
		editor_interface.set_plugin_enabled("node25d", false)
		editor_interface.set_plugin_enabled("node25d", true)
		return
	# 获取编辑场景的 World2D 并赋值给子视口，使预览与编辑场景同步
	var world_2d = edited_scene_root.get_viewport().world_2d
	if world_2d == get_viewport().world_2d:
		return  # 当前打开的是 MainScreen25D 场景本身，跳过
	viewport_2d.world_2d = world_2d


func _process(_delta: float) -> void:
	if not editor_interface:  # 编辑器接口未就绪，跳过
		return

	# 检测视角模式按钮变化
	var view_mode_changed_this_frame: bool = false
	var new_view_mode := -1
	if view_mode_button_group.get_pressed_button():
		new_view_mode = view_mode_button_group.get_pressed_button().get_index()
	if view_mode_index != new_view_mode:
		view_mode_index = new_view_mode
		view_mode_changed_this_frame = true
		# 递归更新编辑场景中所有 Node25D 的视角
		_recursive_change_view_mode(get_tree().edited_scene_root)

	# 鼠标滚轮缩放（在视口区域外也能响应）
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		zoom_level += 1
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		zoom_level -= 1
	var zoom := _get_zoom_amount()

	# 更新子视口尺寸以匹配控件大小
	var vp_size := get_global_rect().size
	viewport_2d.size = vp_size
	viewport_overlay.size = vp_size

	# 计算并应用视口变换（缩放 + 平移）
	var viewport_trans := Transform2D.IDENTITY
	viewport_trans.x *= zoom
	viewport_trans.y *= zoom
	viewport_trans.origin = viewport_trans.basis_xform(viewport_center) + size / 2
	viewport_2d.canvas_transform = viewport_trans
	viewport_overlay.canvas_transform = viewport_trans

	# 清理不再选中的 Gizmo
	var selection := editor_interface.get_selection().get_selected_nodes()
	var gizmos := viewport_overlay.get_children()
	for gizmo in gizmos:
		var contains: bool = false
		for selected in selection:
			if selected == gizmo.node_25d and not view_mode_changed_this_frame:
				contains = true
		if not contains:
			gizmo.queue_free()
	# 为新增选中的 Node25D 创建 Gizmo
	for selected in selection:
		if selected is Node25D:
			_ensure_node25d_has_gizmo(selected, gizmos)
	# 更新所有 Gizmo 的缩放
	for gizmo in gizmos:
		gizmo.set_zoom(zoom)


## 确保指定 Node25D 已有对应的 Gizmo，如果没有则创建。
func _ensure_node25d_has_gizmo(node: Node25D, gizmos: Array[Node]) -> void:
	var new = true
	for gizmo in gizmos:
		if node == gizmo.node_25d:
			return
	var gizmo = gizmo_25d_scene.instantiate()
	viewport_overlay.add_child(gizmo)
	gizmo.setup(node)


## 处理视口区域的鼠标输入事件（缩放、平移、选中拖动）。
func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton:
		if input_event.is_pressed():
			if input_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_level += 1
				accept_event()
			elif input_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_level -= 1
				accept_event()
			elif input_event.button_index == MOUSE_BUTTON_MIDDLE:
				is_panning = true
				pan_center = viewport_center - input_event.position / _get_zoom_amount()
				accept_event()
			elif input_event.button_index == MOUSE_BUTTON_LEFT:
				# 鼠标按下时，通知所有 Gizmo 准备拖动
				var overlay_children := viewport_overlay.get_children()
				for overlay_child in overlay_children:
					overlay_child.wants_to_move = true
				accept_event()
		elif input_event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = false
			accept_event()
		elif input_event.button_index == MOUSE_BUTTON_LEFT:
			# 鼠标释放时，通知所有 Gizmo 停止拖动
			var overlay_children := viewport_overlay.get_children()
			for overlay_child in overlay_children:
				overlay_child.wants_to_move = false
			accept_event()
	elif input_event is InputEventMouseMotion:
		if is_panning:
			# 中键拖拽平移视口
			viewport_center = pan_center + input_event.position / _get_zoom_amount()
			accept_event()


## 递归遍历场景树，为所有具有 set_view_mode 方法的节点设置视角模式。
func _recursive_change_view_mode(current_node: Node) -> void:
	if not current_node:
		return

	if current_node.has_method(&"set_view_mode"):
		current_node.set_view_mode(view_mode_index)

	for child in current_node.get_children():
		_recursive_change_view_mode(child)


## 计算当前缩放等级的缩放倍数。
## 使用 2 的 13 次方根作为底数，每级缩放约 5.5%，共 13 级翻倍。
## 返回: 缩放倍数 (float)
func _get_zoom_amount() -> float:
	const THIRTEENTH_ROOT_OF_2 = 1.05476607648
	var zoom_amount = pow(THIRTEENTH_ROOT_OF_2, zoom_level)
	zoom_label.text = str(round(zoom_amount * 1000) / 10) + "%"
	return zoom_amount


func _on_ZoomOut_pressed() -> void:
	zoom_level -= 1


func _on_ZoomIn_pressed() -> void:
	zoom_level += 1


func _on_ZoomReset_pressed() -> void:
	zoom_level = 0
