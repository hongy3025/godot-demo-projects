## 2.5D 编辑器视口 —— 在编辑器主屏幕中显示 2.5D 场景的预览视口。
##
## 继承自 [Control]，作为编辑器 UI 的一部分。
## 功能：
##   1. 在编辑器中渲染 2.5D 场景的实时预览
##   2. 支持视角模式切换（通过 UI 按钮）
##   3. 支持缩放（滚轮/按钮）和平移（鼠标中键拖拽）
##   4. 为选中的 Node25D 节点显示 3D 操作手柄（Gizmo）
## @tool 注解使其在编辑器中运行
@tool
extends Control

## 当前缩放级别（指数值），通过 pow 计算实际缩放倍数
var zoom_level := 0
## 是否正在平移视口
var is_panning = false
## 平移操作开始时，鼠标按下位置对应的视口中心点
var pan_center: Vector2
## 视口中心位置（用于平移和缩放变换）
var viewport_center: Vector2
## 当前视角模式索引 (0-5)
var view_mode_index := 0

## 编辑器接口引用，在 node25d_plugin.gd 中设置
var editor_interface: EditorInterface
## 标记是否有 Gizmo 正在被拖动移动
var moving = false

## 2D 渲染子视口，用于显示场景内容
## @onready 确保节点就绪后获取引用
@onready var viewport_2d = $Viewport2D
## 视口叠加层，用于显示 Gizmo 手柄
@onready var viewport_overlay = $ViewportOverlay
## 视角模式按钮组，用于获取当前选中的视角模式
@onready var view_mode_button_group: ButtonGroup = $"../TopBar/ViewModeButtons/45Degree".group
## 缩放百分比标签，用于显示当前缩放比例
@onready var zoom_label: Label = $"../TopBar/Zoom/ZoomPercent"
## Gizmo 手柄场景的预加载资源
@onready var gizmo_25d_scene = preload("res://addons/node25d-cs/main_screen/gizmo_25d.tscn")


## _ready 节点就绪时调用，初始化视口。
##
## 功能：
##   等待两帧让场景完全加载，然后获取当前编辑场景的 world_2d，
##   将其赋值给子视口，使子视口能正确渲染编辑场景。
##
## 核心逻辑：
##   使用 await process_frame 等待两帧，确保 Godot 编辑器完全加载。
##   如果编辑场景尚未加载完成，则重新启用插件以触发重新加载。
##   将编辑场景的 world_2d 赋值给子视口，实现场景预览。
func _ready():
	# 等待两帧，让 Godot 完全加载场景
	await get_tree().process_frame
	await get_tree().process_frame
	# 获取当前编辑场景的根节点
	var edited_scene_root = get_tree().edited_scene_root
	if not edited_scene_root:
		# Godot 尚未加载完成，重新启用插件以触发重新加载
		editor_interface.set_plugin_enabled("node25d", false)
		editor_interface.set_plugin_enabled("node25d", true)
		return
	# 获取编辑场景的 world_2d 并赋值给子视口
	var world_2d = edited_scene_root.get_viewport().world_2d
	if world_2d == get_viewport().world_2d:
		return # 当前打开的是 MainScreen25D 场景本身，不做处理
	viewport_2d.world_2d = world_2d


## _process 每帧调用，更新视口状态。
##
## 功能：
##   1. 检测视角模式按钮变化，递归更新场景中所有节点的视角
##   2. 处理滚轮缩放，计算实际缩放倍数
##   3. 更新子视口大小和变换（缩放 + 平移）
##   4. 管理 Gizmo 手柄的创建和销毁
##
## 参数：
##   delta: 帧时间差（秒），此处未使用
##
## 核心逻辑：
##   缩放使用指数函数 pow(1.05476607648, zoom_level)，其中
##   1.05476607648 是 2 的 13 次方根，每 13 级缩放翻倍。
##   视口变换使用 Transform2D 实现缩放和平移。
##   Gizmo 管理：遍历选中节点，为每个 Node25D 创建 Gizmo 手柄。
func _process(delta):
	# 检查编辑器接口是否有效
	if not editor_interface:
		return

	# 检测视角模式是否变化
	var view_mode_changed_this_frame = false
	# 获取当前选中的视角模式按钮索引
	var new_view_mode = view_mode_button_group.get_pressed_button().get_index()
	if view_mode_index != new_view_mode:
		view_mode_index = new_view_mode
		view_mode_changed_this_frame = true
		# 递归更新场景中所有节点的视角模式
		_recursive_change_view_mode(get_tree().edited_scene_root)

	# 处理滚轮缩放
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		zoom_level += 1
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		zoom_level -= 1
	# 计算实际缩放倍数
	var zoom = _get_zoom_amount()

	# 更新子视口大小
	var size = get_global_rect().size
	viewport_2d.size = size

	# 计算视口变换矩阵（缩放 + 平移）
	var viewport_trans = Transform2D.IDENTITY
	viewport_trans.x *= zoom
	viewport_trans.y *= zoom
	# 将视口中心平移到屏幕中心
	viewport_trans.origin = viewport_trans.basis_xform(viewport_center) + size / 2
	# 应用变换到子视口和叠加层
	viewport_2d.canvas_transform = viewport_trans
	viewport_overlay.canvas_transform = viewport_trans

	# 删除不再选中的节点的 Gizmo 手柄
	var selection = editor_interface.get_selection().get_selected_nodes()
	var overlay_children = viewport_overlay.get_children()
	for overlay_child in overlay_children:
		var contains = false
		for selected in selection:
			# 检查 Gizmo 关联的节点是否仍在选中列表中
			if selected == overlay_child.get(&"node25d") and not view_mode_changed_this_frame:
				contains = true
		if not contains:
			# 节点不再选中，删除对应的 Gizmo
			overlay_child.queue_free()

	# 为新选中的 Node25D 节点创建 Gizmo 手柄
	for selected in selection:
		# 检查节点是否有 Node25DReady 方法（判断是否为 Node25D）
		if selected.has_method(&"Node25DReady"):
			var new = true
			# 检查是否已存在对应的 Gizmo
			for overlay_child in overlay_children:
				if selected == overlay_child.get(&"node25d"):
					new = false
			if new:
				# 创建新的 Gizmo 手柄
				var gizmo = gizmo_25d_scene.instantiate()
				viewport_overlay.add_child(gizmo)
				gizmo.set(&"node25d", selected)
				gizmo.call(&"Initialize")


## _gui_input 处理视口内的 GUI 输入事件。
##
## 功能：
##   处理鼠标事件：
##   - 滚轮上/下：缩放
##   - 鼠标中键按下/释放：开始/结束平移
##   - 鼠标左键按下/释放：标记 Gizmo 开始/结束移动
##   - 鼠标移动（平移中）：更新视口中心位置
##
## 参数：
##   event: 输入事件对象
##
## 核心逻辑：
##   使用 accept_event() 阻止事件继续传播。
##   平移时计算 pan_center 和 event.position 的差值来移动视口。
func _gui_input(event):
	# 处理鼠标按钮事件
	if event is InputEventMouseButton:
		if event.is_pressed():
			# 滚轮向上：放大
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_level += 1
				accept_event()
			# 滚轮向下：缩小
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_level -= 1
				accept_event()
			# 鼠标中键按下：开始平移
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				is_panning = true
				# 记录平移起始点
				pan_center = viewport_center - event.position
				accept_event()
			# 鼠标左键按下：标记 Gizmo 开始移动
			elif event.button_index == MOUSE_BUTTON_LEFT:
				var overlay_children = viewport_overlay.get_children()
				for overlay_child in overlay_children:
					overlay_child.set(&"wantsToMove", true)
				accept_event()
		else: # 鼠标按钮释放
			# 鼠标中键释放：结束平移
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				is_panning = false
				accept_event()
			# 鼠标左键释放：标记 Gizmo 结束移动
			elif event.button_index == MOUSE_BUTTON_LEFT:
				var overlay_children = viewport_overlay.get_children()
				for overlay_child in overlay_children:
					overlay_child.set(&"wantsToMove", false)
				accept_event()
	# 处理鼠标移动事件
	elif event is InputEventMouseMotion:
		if is_panning:
			# 更新视口中心位置实现平移
			viewport_center = pan_center + event.position
			accept_event()


## 递归更改场景中所有节点的视角模式。
##
## 功能：
##   从当前节点开始，递归遍历所有子节点，
##   对支持 set_view_mode 或 SetViewMode 方法的节点
##   调用对应的方法更新视角模式。
##
## 参数：
##   current_node: 当前遍历的节点
##
## 核心逻辑：
##   同时支持 GDScript 的 set_view_mode 和 C# 的 SetViewMode，
##   确保两种语言实现的节点都能被正确更新。
func _recursive_change_view_mode(current_node):
	# 调用 GDScript 节点的 set_view_mode 方法
	if current_node.has_method(&"set_view_mode"):
		current_node.set_view_mode(view_mode_index)
	# 调用 C# 节点的 SetViewMode 方法
	if current_node.has_method(&"SetViewMode"):
		current_node.call(&"SetViewMode", view_mode_index)
	# 递归处理所有子节点
	for child in current_node.get_children():
		_recursive_change_view_mode(child)


## 计算当前缩放级别的实际缩放倍数并更新标签。
##
## 功能：
##   使用指数函数计算缩放倍数，公式为 pow(base, zoom_level)。
##   同时更新 UI 中的缩放百分比标签。
##
## 返回: [float] 当前缩放倍数
##
## 核心逻辑：
##   底数 1.05476607648 是 2 的 13 次方根，
##   即每 13 级缩放倍数翻倍（zoom_level=13 时返回 2.0）。
func _get_zoom_amount():
	# 计算缩放倍数：pow(1.05476607648, zoom_level)
	var zoom_amount = pow(1.05476607648, zoom_level) # 2 的 13 次方根
	# 更新缩放百分比标签（保留一位小数）
	zoom_label.text = str(round(zoom_amount * 1000) / 10) + "%"
	return zoom_amount


## 缩小按钮的回调函数。
func _on_ZoomOut_pressed():
	zoom_level -= 1


## 放大按钮的回调函数。
func _on_ZoomIn_pressed():
	zoom_level += 1


## 重置缩放按钮的回调函数。
func _on_ZoomReset_pressed():
	zoom_level = 0
