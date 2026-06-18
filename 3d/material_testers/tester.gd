## 材质测试演示场景的主控制器。
##
## 继承自 [Node3D]，管理多个材质测试场景的切换、摄像机控制、
## 背景切换和反射探针模式切换。
extends Node3D


## 摄像机插值速度。
const INTERP_SPEED = 2
## 鼠标旋转灵敏度。
const ROT_SPEED = 0.003
## 滚轮缩放速度。
const ZOOM_SPEED = 0.1
## 最大缩放值。
const ZOOM_MAX = 2.5
## 鼠标拖拽旋转所需的按键掩码。
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT

## 当前测试场景的索引。
var tester_index := 0
## 摄像机 X 轴旋转角度（俯仰），需与 RotationX 节点同步。
var rot_x := -0.5
## 摄像机 Y 轴旋转角度（偏航），需与 CameraHolder 节点同步。
var rot_y := -0.5
## 摄像机缩放值。
var zoom := 5.0

## 可用背景列表，每个元素包含路径和名称。
var backgrounds: Array[Dictionary] = [
	{ path = "res://backgrounds/schelde.hdr", name = "河畔" },
	{ path = "res://backgrounds/lobby.hdr", name = "大厅" },
	{ path = "res://backgrounds/park.hdr", name = "公园" },
	{ path = "res://backgrounds/night.hdr", name = "夜晚" },
	{ path = "res://backgrounds/experiment.hdr", name = "实验" },
]

## 所有测试场景的父节点。
@onready var testers: Node3D = $Testers
## 材质名称显示标签。
@onready var material_name: Label = $UI/MaterialName

## 摄像机支架，控制 Y 轴旋转和 X 轴位置。
@onready var camera_holder: Node3D = $CameraHolder
## 摄像机 X 轴旋转节点。
@onready var rotation_x: Node3D = $CameraHolder/RotationX
## 实际渲染用的 Camera3D 节点。
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera


## _ready 入口。初始化兼容模式、背景选项和 UI。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 调整场景亮度以匹配 Forward+/Mobile 渲染器。
		$WorldEnvironment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		$WorldEnvironment.environment.background_energy_multiplier = 2.0

	for background in backgrounds:
		get_node(^"UI/Background").add_item(background.name)

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
		zoom = clamp(zoom, 2, 8)
		camera.position.z = zoom

	if input_event is InputEventMouseMotion and input_event.button_mask & MAIN_BUTTONS:
		# 使用 `screen_relative` 使鼠标灵敏度不受视口分辨率影响。
		var relative_motion: Vector2 = input_event.screen_relative
		rot_y -= relative_motion.x * ROT_SPEED
		rot_y = clamp(rot_y, -1.95, 1.95)
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.4, 0.45)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


## _process 入口。每帧平滑移动摄像机到当前测试场景位置。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# 假设 CameraHolder 的 Y 和 Z 坐标已正确设置。
	var target_position := current_tester.transform.origin.x
	var current_position := camera_holder.transform.origin.x
	camera_holder.transform.origin.x = lerp(current_position, target_position, INTERP_SPEED * delta)


## 切换到上一个测试场景。
func _on_previous_pressed() -> void:
	if tester_index > 0:
		tester_index -= 1

	update_gui()


## 切换到下一个测试场景。
func _on_next_pressed() -> void:
	if tester_index < testers.get_child_count() - 1:
		tester_index += 1

	update_gui()


## 更新 UI 显示：材质名称、前后按钮状态。
func update_gui() -> void:
	var current_tester := testers.get_child(tester_index)
	material_name.text = current_tester.get_name()
	$UI/Previous.disabled = tester_index == 0
	$UI/Next.disabled = tester_index == testers.get_child_count() - 1


## 背景选择回调。切换天空盒并强制更新反射探针。
##
## 参数:
##   index: 背景索引
func _on_bg_item_selected(index: int) -> void:
	var sky_material: PanoramaSkyMaterial = $WorldEnvironment.environment.sky.sky_material

	sky_material.panorama = load(backgrounds[index].path)

	# 轻微移动反射探针以强制其更新。
	for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
		reflection_probe.position.y += randf_range(-0.0001, 0.0001)


## 反射探针模式选择回调。
##
## 参数:
##   index: 反射探针模式索引
func _on_reflection_probes_item_selected(index: int) -> void:
	match index:
		0:  # 无反射探针
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = false

		1:  # 反射探针（仅反射）
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = true
				reflection_probe.ambient_mode = ReflectionProbe.AMBIENT_DISABLED

		2:  # 反射探针（反射 + 环境）
			for reflection_probe: ReflectionProbe in get_tree().get_nodes_in_group(&"reflection_probe"):
				reflection_probe.visible = true
				reflection_probe.ambient_mode = ReflectionProbe.AMBIENT_ENVIRONMENT


## 退出按钮回调。
func _on_quit_pressed() -> void:
	get_tree().quit()
