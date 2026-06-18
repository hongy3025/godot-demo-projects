## 体积雾演示场景的摄像机控制器。
##
## 继承自 [Camera3D]，支持自由飞行、体积雾参数实时调节和快捷键控制。
## 可调节参数：雾密度、时域重投影开关/强度、体积雾质量。
extends Camera3D

## 鼠标灵敏度系数。
const MOUSE_SENSITIVITY = 0.002
## 移动速度。
const MOVE_SPEED = 0.6

## 体积雾的体素大小（从项目设置读取）。
var volumetric_fog_volume_size := int(ProjectSettings.get_setting("rendering/environment/volumetric_fog/volume_size"))
## 体积雾的体素深度（从项目设置读取）。
var volumetric_fog_volume_depth := int(ProjectSettings.get_setting("rendering/environment/volumetric_fog/volume_depth"))

## 摄像机旋转欧拉角（弧度）。
var rot := Vector3()
## 摄像机移动速度向量，用于实现惯性效果。
var velocity := Vector3()

## 显示当前体积雾参数的 Label 节点。
@onready var label: Label = $Label

## _ready 入口。捕获鼠标并更新标签显示。
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_label()


## _process 入口。处理 WASD 移动。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	var motion := Vector3(
			Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left"),
			0,
			Input.get_action_strength(&"move_back") - Input.get_action_strength(&"move_forward")
		)

	# 归一化防止对角线移动速度比直线移动快 `sqrt(2)` 倍。
	motion = motion.normalized()

	velocity += MOVE_SPEED * delta * (transform.basis * motion)
	velocity *= 0.85
	position += velocity


## _input 入口。处理鼠标视角和体积雾参数调节快捷键。
##
## 参数:
##   input_event: 输入事件对象
##
## 快捷键功能：
## - 鼠标移动（捕获时）：视角旋转
## - toggle_mouse_capture: 切换鼠标捕获
## - toggle_temporal_reprojection: 切换时域重投影
## - increase/decrease_temporal_reprojection: 调节重投影强度
## - increase/decrease_fog_density: 调节雾密度
## - increase/decrease_volumetric_fog_quality: 调节体积雾质量
func _input(input_event: InputEvent) -> void:
	# 鼠标视角（仅在鼠标被捕获时生效）。
	if input_event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rot.y -= input_event.screen_relative.x * MOUSE_SENSITIVITY
		rot.x = clamp(rot.x - input_event.screen_relative.y * MOUSE_SENSITIVITY, -1.57, 1.57)
		transform.basis = Basis.from_euler(rot)

	if input_event.is_action_pressed(&"toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if input_event.is_action_pressed(&"toggle_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled = not get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled
		update_label()
	elif input_event.is_action_pressed(&"increase_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_amount = clamp(get_world_3d().environment.volumetric_fog_temporal_reprojection_amount + 0.01, 0.5, 0.99)
		update_label()
	elif input_event.is_action_pressed(&"decrease_temporal_reprojection"):
		get_world_3d().environment.volumetric_fog_temporal_reprojection_amount = clamp(get_world_3d().environment.volumetric_fog_temporal_reprojection_amount - 0.01, 0.5, 0.99)
		update_label()
	elif input_event.is_action_pressed(&"increase_fog_density"):
		get_world_3d().environment.volumetric_fog_density = clamp(get_world_3d().environment.volumetric_fog_density + 0.01, 0.0, 1.0)
		update_label()
	elif input_event.is_action_pressed(&"decrease_fog_density"):
		get_world_3d().environment.volumetric_fog_density = clamp(get_world_3d().environment.volumetric_fog_density - 0.01, 0.0, 1.0)
		update_label()
	elif input_event.is_action_pressed(&"increase_volumetric_fog_quality"):
		volumetric_fog_volume_size = clamp(volumetric_fog_volume_size + 16, 16, 384)
		volumetric_fog_volume_depth = clamp(volumetric_fog_volume_depth + 16, 16, 384)
		RenderingServer.environment_set_volumetric_fog_volume_size(volumetric_fog_volume_size, volumetric_fog_volume_depth)
		update_label()
	elif input_event.is_action_pressed(&"decrease_volumetric_fog_quality"):
		volumetric_fog_volume_size = clamp(volumetric_fog_volume_size - 16, 16, 384)
		volumetric_fog_volume_depth = clamp(volumetric_fog_volume_depth - 16, 16, 384)
		RenderingServer.environment_set_volumetric_fog_volume_size(volumetric_fog_volume_size, volumetric_fog_volume_depth)
		update_label()


## 更新标签显示当前体积雾参数。
func update_label() -> void:
	if get_world_3d().environment.volumetric_fog_temporal_reprojection_enabled:
		label.text = "雾密度: %.2f\n时域重投影: 已启用\n时域重投影强度: %.2f\n体积雾质量: %d×%d×%d" % [
				get_world_3d().environment.volumetric_fog_density,
				get_world_3d().environment.volumetric_fog_temporal_reprojection_amount,
				volumetric_fog_volume_size,
				volumetric_fog_volume_size,
				volumetric_fog_volume_depth,
			]
	else:
		label.text = "雾密度: %.2f\n时域重投影: 已禁用\n体积雾质量: %d×%d×%d" % [
				get_world_3d().environment.volumetric_fog_density,
				volumetric_fog_volume_size,
				volumetric_fog_volume_size,
				volumetric_fog_volume_depth,
			]
