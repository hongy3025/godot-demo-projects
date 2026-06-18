## 贴花（Decal）演示场景的主控制器。
##
## 继承自 [WorldEnvironment]，管理多个贴花测试场景的切换、摄像机控制
## 和贴花放置功能。支持鼠标点击在 3D 表面放置贴花。
extends WorldEnvironment


## 鼠标旋转灵敏度。
const ROT_SPEED = 0.003
## 滚轮缩放速度。
const ZOOM_SPEED = 0.125
## 鼠标拖拽旋转所需的按键掩码（左键 | 右键 | 中键）。
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

## 当前测试场景的索引。
var tester_index := 0
## 摄像机 X 轴旋转角度（俯仰），需与 RotationX 节点同步。
var rot_x := deg_to_rad(-22.5)
## 摄像机 Y 轴旋转角度（偏航），需与 CameraHolder 节点同步。
var rot_y := deg_to_rad(90)
## 摄像机缩放值。
var zoom := 1.5

## 所有测试场景的父节点。
@onready var testers: Node3D = $Testers
## 摄像机支架，控制 Y 轴旋转和 Z 轴位置。
@onready var camera_holder: Node3D = $CameraHolder
## 摄像机 X 轴旋转节点。
@onready var rotation_x: Node3D = $CameraHolder/RotationX
## 实际渲染用的 Camera3D 节点。
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D


## _ready 入口。初始化摄像机位置和 UI。
func _ready() -> void:
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


## _unhandled_input 入口。处理场景切换、贴花放置、缩放和旋转。
##
## 参数:
##   input_event: 输入事件对象
##
## 贴花放置逻辑：
## 1. 从摄像机位置向鼠标方向发射射线
## 2. 检测与 3D 物体的碰撞点
## 3. 在碰撞点实例化贴花
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if input_event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if input_event.is_action_pressed(&"place_decal"):
		var origin := camera.global_position
		var target := camera.project_position(get_viewport().get_mouse_position(), 100)

		# 创建 3D 射线检测参数。
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			# 在碰撞点实例化贴花。
			var decal := preload("res://decal.tscn").instantiate()
			add_child(decal)
			decal.get_node(^"Decal").modulate = Color(1.0,0.0,0)
			decal.position = result["position"]
			# 贴花朝向与摄像机一致。
			decal.transform.basis = camera.global_transform.basis

	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if input_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 1.5, 4)

	if input_event is InputEventMouseMotion and input_event.button_mask & MAIN_BUTTONS:
		# 使用 `screen_relative` 使鼠标灵敏度不受视口分辨率影响。
		var relative_motion: Vector2 = input_event.screen_relative
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, deg_to_rad(-90), 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


## _process 入口。每帧平滑移动摄像机到当前测试场景位置。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# 假设 CameraHolder 的 X 和 Y 坐标已正确设置。
	var current_position := camera_holder.global_transform.origin.z
	var target_position := current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position, target_position, 3 * delta)
	camera.position.z = lerpf(camera.position.z, zoom, 10 * delta)


## 切换到上一个测试场景。
func _on_previous_pressed() -> void:
	tester_index = max(0, tester_index - 1)
	update_gui()


## 切换到下一个测试场景。
func _on_next_pressed() -> void:
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


## 更新 UI 显示：测试名称、前后按钮状态。
func update_gui() -> void:
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


## 贴花过滤模式选择回调。
##
## 参数:
##   index: OptionButton 中的索引，对应 RenderingServer 的贴花过滤常量
func _on_decal_filter_mode_item_selected(index: int) -> void:
	RenderingServer.decals_set_filter(index)
