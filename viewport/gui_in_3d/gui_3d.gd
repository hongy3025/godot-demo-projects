## 3D 中的 GUI 交互 —— 将 2D 界面渲染到 3D 空间的 Quad 上，并支持鼠标/触摸交互。
##
## 继承自 [Node3D]，实现将 SubViewport 中的 2D UI 投射到 3D Quad 表面，
## 并通过 Area3D 的物理拾取（Physics Picking）将 3D 空间中的鼠标事件
## 转换为 2D 视口坐标，实现与 2D UI 的交互。
##
## 核心流程：
##   1. Area3D 检测鼠标进入/退出/点击事件
##   2. 将 3D 事件位置转换为 SubViewport 的 2D 坐标
##   3. 通过 push_input 将事件注入 SubViewport
extends Node3D

## 鼠标是否在 Area3D 范围内。
var is_mouse_inside: bool = false

## 上一次处理的鼠标/触摸事件位置，用于计算相对移动量。
var last_event_pos2D := Vector2()

## 上一次事件发生的时间（秒，自引擎启动），用于计算速度。
var last_event_time := -1.0

## 承载 2D UI 的子视口。
@onready var node_viewport: SubViewport = $SubViewport
## 显示子视口纹理的 3D Quad 网格。
@onready var node_quad: MeshInstance3D = $Quad
## 用于检测鼠标交互的 Area3D 节点。
@onready var node_area: Area3D = $Quad/Area3D


## 初始化：连接 Area3D 的信号，根据材质是否为公告牌模式决定是否启用 _process。
func _ready() -> void:
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)

	# 如果材质未启用公告牌模式，则禁用 _process 以节省性能
	if node_quad.get_surface_override_material(0).billboard_mode == BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED:
		set_process(false)


## 每帧更新：如果材质启用了公告牌模式，旋转 Area3D 使其始终面向摄像机。
func _process(_delta: float) -> void:
	rotate_area_to_billboard()


## 处理鼠标进入 Area3D 的事件：标记鼠标在区域内，通知视口鼠标进入。
func _mouse_entered_area() -> void:
	is_mouse_inside = true
	node_viewport.notification(NOTIFICATION_VP_MOUSE_ENTER)


## 处理鼠标离开 Area3D 的事件：通知视口鼠标离开，标记鼠标不在区域内。
func _mouse_exited_area() -> void:
	node_viewport.notification(NOTIFICATION_VP_MOUSE_EXIT)
	is_mouse_inside = false


## 处理非鼠标/触摸的输入事件（如键盘），直接推送到子视口。
## 参数:
##   input_event: 输入事件对象
##
## 鼠标和触摸事件由 Area3D 的物理拾取处理，此函数忽略它们。
func _unhandled_input(input_event: InputEvent) -> void:
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(input_event, mouse_event):
			return
	node_viewport.push_input(input_event)


## 处理 Area3D 上的鼠标/触摸输入事件：将 3D 事件位置转换为子视口的 2D 坐标并推送。
##
## 参数:
##   _camera: 触发拾取的摄像机
##   input_event: 输入事件对象
##   event_position: 事件在 3D 空间中的位置
##   _normal: 碰撞法线
##   _shape_idx: 碰撞形状索引
##
## 坐标转换流程：
##   1. 将事件位置从世界空间转换到 Quad 的局部空间
##   2. 从 (-quad_size/2, quad_size/2) 范围映射到 (0, 1) 范围
##   3. 从 (0, 1) 范围映射到 (0, viewport.size) 范围
##   4. 计算鼠标相对移动量和速度
##   5. 通过 push_input 将事件注入子视口
func _mouse_input_event(_camera: Camera3D, input_event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var quad_mesh_size: Vector2 = node_quad.mesh.size

	var event_pos3D := event_position

	var now := Time.get_ticks_msec() / 1000.0

	# 将事件位置从世界坐标转换到 Quad 的局部坐标
	# affine_inverse() 会考虑节点的缩放、旋转和位移
	event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

	var event_pos2D := Vector2()

	if is_mouse_inside:
		# 将 3D 坐标映射到 2D（Y 轴取反，因为 3D 和 2D 的 Y 轴方向相反）
		event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)

		# 从 (-quad_size/2, quad_size/2) 映射到 (-0.5, 0.5)
		event_pos2D.x = event_pos2D.x / quad_mesh_size.x
		event_pos2D.y = event_pos2D.y / quad_mesh_size.y
		# 从 (-0.5, 0.5) 映射到 (0, 1)
		event_pos2D.x += 0.5
		event_pos2D.y += 0.5

		# 从 (0, 1) 映射到 (0, viewport.size)
		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y

	elif last_event_pos2D != null:
		event_pos2D = last_event_pos2D

	# 设置事件在视口坐标系中的位置
	input_event.position = event_pos2D
	if input_event is InputEventMouse:
		input_event.global_position = event_pos2D

	# 计算鼠标相对移动量和速度
	if input_event is InputEventMouseMotion or input_event is InputEventScreenDrag:
		if last_event_pos2D == null:
			input_event.relative = Vector2(0, 0)
		else:
			input_event.relative = event_pos2D - last_event_pos2D
			input_event.velocity = input_event.relative / (now - last_event_time)

	last_event_pos2D = event_pos2D
	last_event_time = now

	# 将处理后的输入事件推送到子视口
	node_viewport.push_input(input_event)


## 旋转 Area3D 以匹配材质的公告牌（Billboard）模式。
## 支持禁用、常规公告牌和 Y 轴锁定公告牌三种模式。
## 在 Y 轴锁定模式下，仅绕 Y 轴旋转，避免摄像机倾斜时画面扭曲。
func rotate_area_to_billboard() -> void:
	var billboard_mode: BaseMaterial3D.BillboardMode = node_quad.get_surface_override_material(0).billboard_mode

	if billboard_mode > 0:
		var camera := get_viewport().get_camera_3d()
		# 计算从摄像机指向 Quad 的方向向量
		var look := camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		look = node_area.position + look

		# Y-Billboard 模式：锁定 Y 轴旋转，仅绕 Y 轴朝向摄像机
		if billboard_mode == 2:
			look = Vector3(look.x, 0, look.z)

		node_area.look_at(look, Vector3.UP)

		# 在 Z 轴旋转以补偿摄像机的倾斜
		node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)
