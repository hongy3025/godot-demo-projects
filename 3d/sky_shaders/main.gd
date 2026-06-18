## 天空着色器演示场景的主控制器。
##
## 继承自 [Node3D]，提供天空着色器的实时调节 UI，包括：
## - 昼夜时间控制（动画播放/暂停/速度调节）
## - 云层参数（覆盖率、密度）
## - 天空处理模式（质量/增量/实时）和辐射度大小
## - 摄像机 FOV 调节和鼠标视角控制
extends Node3D


## 鼠标灵敏度系数。
const MOUSE_SENSITIVITY = 0.001

## 摄像机目标 FOV，用于平滑插值。
@onready var desired_fov: float = $YawCamera/Camera3D.fov


## _ready 入口。启动时捕获鼠标。
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## _process 入口。每帧更新 UI 滑块、云偏移和摄像机 FOV 插值。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	# 让滑块跟随昼夜动画进度。
	$Panel/MarginContainer/VBoxContainer/TimeOfDay/HSlider.value = $AnimationPlayer.current_animation_position
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_time_offset", $AnimationPlayer.current_animation_position)

	# 使用指数平滑插值摄像机 FOV。
	$YawCamera/Camera3D.fov = lerpf($YawCamera/Camera3D.fov, desired_fov, 1.0 - exp(-delta * 10.0))



## _input 入口。处理快捷键和鼠标视角控制。
##
## 参数:
##   input_event: 输入事件对象
##
## 快捷键功能：
## - toggle_gui: 切换 UI 面板和帮助文本可见性
## - toggle_spheres: 切换球体可见性
## - toggle_mouse_capture: 切换鼠标捕获
## - 鼠标移动（捕获时）：视角旋转
## - 滚轮/快捷键：调节 FOV
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_gui"):
		$Panel.visible = not $Panel.visible
		$Help.visible = not $Help.visible

	if input_event.is_action_pressed(&"toggle_spheres"):
		$Spheres.visible = not $Spheres.visible

	if input_event.is_action_pressed(&"toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and input_event is InputEventMouseMotion:
		# 鼠标视角控制。
		var relative_motion: Vector2 = input_event.screen_relative
		$YawCamera.rotation.x = clampf($YawCamera.rotation.x - relative_motion.y * MOUSE_SENSITIVITY, -TAU * 0.25, TAU * 0.25)
		$YawCamera.rotation.y -= relative_motion.x * MOUSE_SENSITIVITY

	# 鼠标滚轮目前在输入动作中无法正常工作，手动处理。
	if input_event.is_action_pressed(&"increase_camera_fov") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		desired_fov = clampf(desired_fov + 5.0, 20.0, 120.0)
	if input_event.is_action_pressed(&"decrease_camera_fov") or Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		desired_fov = clampf(desired_fov - 5.0, 20.0, 120.0)


## 时间滑块值变化回调。更新动画播放位置。
##
## 参数:
##   value: 动画进度值
func _on_time_of_day_value_changed(value: float) -> void:
	$AnimationPlayer.seek(value)
	$Panel/MarginContainer/VBoxContainer/TimeOfDay/Value.text = str(value).pad_decimals(2)


## 减速按钮回调。降低动画播放速度。
func _on_speed_minus_pressed() -> void:
	$AnimationPlayer.speed_scale = clampf($AnimationPlayer.speed_scale * 0.5, 0.0, 12.8)
	if $AnimationPlayer.speed_scale < 0.0499:
		# 低于 0.5× 速度时暂停。
		$AnimationPlayer.speed_scale = 0.0

	update_speed_label()


## 加速按钮回调。提高动画播放速度。
func _on_speed_plus_pressed() -> void:
	$AnimationPlayer.speed_scale = clampf($AnimationPlayer.speed_scale * 2.0, 0.05, 12.8)
	if is_zero_approx($AnimationPlayer.speed_scale):
		# 当前暂停，恢复播放。
		$AnimationPlayer.speed_scale = 0.1

	update_speed_label()


## 更新速度显示标签。
##
## 此 AnimationPlayer 的默认速度倍率内部为 0.1，因此显示值需乘以 10。
func update_speed_label() -> void:
	if is_zero_approx($AnimationPlayer.speed_scale):
		$Panel/MarginContainer/VBoxContainer/TimeOfDay/CurrentSpeed.text = "暂停"
	else:
		$Panel/MarginContainer/VBoxContainer/TimeOfDay/CurrentSpeed.text = "%.2f×" % ($AnimationPlayer.speed_scale * 10)


## 云覆盖率滑块值变化回调。
##
## 参数:
##   value: 云覆盖率（0~1）
func _on_cloud_coverage_value_changed(value: float) -> void:
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_coverage", value)
	$Panel/MarginContainer/VBoxContainer/Clouds/CoverageValue.text = "%d%%" % (value * 100)


## 云密度滑块值变化回调。
##
## 参数:
##   value: 云密度（0~1）
func _on_cloud_density_value_changed(value: float) -> void:
	$WorldEnvironment.environment.sky.sky_material.set_shader_parameter(&"cloud_density", value)
	$Panel/MarginContainer/VBoxContainer/Clouds/DensityValue.text = "%d%%" % (value * 100)


## 天空处理模式选项选择回调。
##
## 参数:
##   index: 处理模式索引（质量/增量/实时）
func _on_process_mode_item_selected(index: int) -> void:
	match index:
		0:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_QUALITY
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = true
			_on_radiance_size_item_selected($Panel/MarginContainer/VBoxContainer/RadianceSize/OptionButton.selected)
		1:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = true
			_on_radiance_size_item_selected($Panel/MarginContainer/VBoxContainer/RadianceSize/OptionButton.selected)
		2:
			$WorldEnvironment.environment.sky.process_mode = Sky.PROCESS_MODE_REALTIME
			# 实时模式下引擎强制辐射度大小为 256。
			$Panel/MarginContainer/VBoxContainer/RadianceSize.visible = false


## 辐射度大小选项选择回调。
##
## 参数:
##   index: 辐射度大小索引（32/64/128/256/512）
func _on_radiance_size_item_selected(index: int) -> void:
	match index:
		0:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_32
		1:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_64
		2:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_128
		3:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_256
		4:
			$WorldEnvironment.environment.sky.radiance_size = Sky.RADIANCE_SIZE_512
