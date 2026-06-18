## 程序化材质演示场景的主控制器。
##
## 继承自 [WorldEnvironment]，管理多个程序化材质测试场景的切换和摄像机控制。
extends WorldEnvironment


## 鼠标旋转灵敏度。
const ROT_SPEED = 0.003
## 滚轮缩放速度。
const ZOOM_SPEED = 0.125
## 鼠标拖拽旋转所需的按键掩码（左键 | 右键 | 中键）。
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

## 当前测试场景的索引。
var tester_index: int = 0
## 摄像机 X 轴旋转角度（俯仰），需与 RotationX 节点同步。
var rot_x: float = deg_to_rad(-22.5)
## 摄像机 Y 轴旋转角度（偏航），需与 CameraHolder 节点同步。
var rot_y: float = deg_to_rad(90)
## 摄像机缩放值。
var zoom: float = 2.5
## 是否为兼容渲染模式。
var is_compatibility: bool = false

## 所有测试场景的父节点。
@onready var testers: Node3D = $Testers
## 摄像机支架，控制 Y 轴旋转和 Z 轴位置。
@onready var camera_holder: Node3D = $CameraHolder
## 摄像机 X 轴旋转节点。
@onready var rotation_x: Node3D = $CameraHolder/RotationX
## 实际渲染用的 Camera3D 节点。
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D


## _ready 入口。初始化兼容模式、摄像机位置和 UI。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 使用 PCF13 软阴影提高质量（Medium 模式下默认使用 PCF5）。
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $DirectionalLight3D.duplicate()
		new_light.light_energy = 0.25
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)

	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


## _unhandled_input 入口。处理场景切换、缩放和旋转。
##
## 参数:
##   input_event: 输入事件对象
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if input_event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

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
