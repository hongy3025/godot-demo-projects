## 物理光相机单位演示场景的选项控制器。
##
## 继承自 [Control]，提供物理单位制下光源和摄像机参数的实时调节 UI。
## 包括：时间（日照角度）、光源强度（勒克斯/流明）、色温、摄像机对焦/焦距/光圈/快门/ISO 等。
extends Control


## 太阳光 DirectionalLight3D 引用。
@export var sun: DirectionalLight3D
## 灯泡1 OmniLight3D 引用。
@export var lightbulb_1: OmniLight3D
## 灯泡2 OmniLight3D 引用。
@export var lightbulb_2: OmniLight3D
## 世界环境引用。
@export var world_environment: WorldEnvironment


## 根据色温（开尔文）返回对应的颜色值。
##
## 参数:
##   p_temperature: 色温值（1000~15000K），6500K 接近白色
##
## 返回: [Color] 对应的 sRGB 颜色
##
## 算法来源：Filament 文档
## https://google.github.io/filament/Filament.md.html#lighting/directlighting/lightsparameterization
## 与引擎内部 Light3D.light_temperature 使用的函数相同，转换为 GDScript 实现。
func get_color_from_temperature(p_temperature: float) -> Color:
	var t2 := p_temperature * p_temperature
	var u := (
			(0.860117757 + 1.54118254e-4 * p_temperature + 1.28641212e-7 * t2) /
			(1.0 + 8.42420235e-4 * p_temperature + 7.08145163e-7 * t2)
		)
	var v := (
			(0.317398726 + 4.22806245e-5 * p_temperature + 4.20481691e-8 * t2) /
			(1.0 - 2.89741816e-5 * p_temperature + 1.61456053e-7 * t2)
		)

	# 转换为 xyY 色彩空间。
	var d := 1.0 / (2.0 * u - 8.0 * v + 4.0)
	var x := 3.0 * u * d
	var y := 2.0 * v * d

	# 转换为 XYZ 色彩空间。
	var a := 1.0 / maxf(y, 1e-5)
	var xyz := Vector3(x * a, 1.0, (1.0 - x - y) * a)

	# 从 XYZ 转换为 sRGB（线性空间）。
	var linear := Vector3(
			3.2404542 * xyz.x - 1.5371385 * xyz.y - 0.4985314 * xyz.z,
			-0.9692660 * xyz.x + 1.8760108 * xyz.y + 0.0415560 * xyz.z,
			0.0556434 * xyz.x - 0.2040259 * xyz.y + 1.0572252 * xyz.z
		)
	linear /= maxf(1e-5, linear[linear.max_axis_index()])
	# 归一化、钳制并转换为 sRGB。
	return Color(linear.x, linear.y, linear.z).clamp().linear_to_srgb()


## 时间滑块值变化回调。根据时间（分钟）旋转太阳光并控制可见性。
##
## 参数:
##   value: 一天中的分钟数（0~1440）
func _on_time_of_day_value_changed(value: float) -> void:
	var offset := TAU * 0.25
	sun.rotation.x = remap(value, 0, 1440, 0 + offset, TAU + offset)

	# 太阳低于地平线时隐藏，防止漏光。
	const EPSILON = 0.0001
	sun.visible = sun.rotation.x > TAU * 0.5 + EPSILON and sun.rotation.x < TAU - EPSILON

	$Light/TimeOfDay/Value.text = "%02d:%02d" % [value / 60, fmod(value, 60)]


## 太阳强度滑块值变化回调。
##
## 参数:
##   value: 光照强度（勒克斯）
func _on_sun_intensity_value_changed(value: float) -> void:
	sun.light_intensity_lux = value
	$Light/SunIntensity/Value.text = "%d lux" % value


## 灯泡1强度滑块值变化回调。
##
## 参数:
##   value: 光通量（流明）
func _on_lightbulb1_intensity_value_changed(value: float) -> void:
	lightbulb_1.light_intensity_lumens = value
	$Light/Lightbulb1Intensity/Value.text = "%d lm" % value


## 灯泡1色温滑块值变化回调。
##
## 参数:
##   value: 色温（开尔文）
func _on_lightbulb1_temperature_value_changed(value: float) -> void:
	lightbulb_1.light_temperature = value
	$Light/Lightbulb1Temperature/Value.text = "%d K" % value
	$Light/Lightbulb1Temperature/Value.add_theme_color_override(&"font_color", get_color_from_temperature(value))


## 灯泡2强度滑块值变化回调。
##
## 参数:
##   value: 光通量（流明）
func _on_lightbulb2_intensity_value_changed(value: float) -> void:
	lightbulb_2.light_intensity_lumens = value
	$Light/Lightbulb2Intensity/Value.text = "%d lm" % value


## 灯泡2色温滑块值变化回调。
##
## 参数:
##   value: 色温（开尔文）
func _on_lightbulb2_temperature_value_changed(value: float) -> void:
	lightbulb_2.light_temperature = value
	$Light/Lightbulb2Temperature/Value.text = "%d K" % value
	$Light/Lightbulb2Temperature/Value.add_theme_color_override(&"font_color", get_color_from_temperature(value))


## 对焦距离滑块值变化回调。
##
## 参数:
##   value: 对焦距离（米）
func _on_focus_distance_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.frustum_focus_distance = value
	$Camera/FocusDistance/Value.text = "%.1f m" % value


## 焦距滑块值变化回调。
##
## 参数:
##   value: 焦距（毫米）
func _on_focal_length_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.frustum_focal_length = value
	$Camera/FocalLength/Value.text = "%d mm" % value


## 光圈滑块值变化回调。
##
## 参数:
##   value: 光圈值（f-stop）
func _on_aperture_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_aperture = value
	$Camera/Aperture/Value.text = "%.1f f-stop" % value


## 快门速度滑块值变化回调。
##
## 参数:
##   value: 快门速度分母
func _on_shutter_speed_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_shutter_speed = value
	$Camera/ShutterSpeed/Value.text = "1/%d" % value


## ISO 感光度滑块值变化回调。
##
## 参数:
##   value: ISO 值
func _on_sensitivity_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.exposure_sensitivity = value
	$Camera/Sensitivity/Value.text = "%d ISO" % value


## 自动曝光速度滑块值变化回调。
##
## 参数:
##   value: 自动曝光适应速度
func _on_autoexposure_speed_value_changed(value: float) -> void:
	get_viewport().get_camera_3d().attributes.auto_exposure_speed = value
	$Camera/AutoexposureSpeed/Value.text = "%.1f" % value


## SDFGI 开关按钮回调。
##
## 参数:
##   button_pressed: 是否启用 SDFGI
func _on_sdfgi_button_toggled(button_pressed: bool) -> void:
	world_environment.environment.sdfgi_enabled = button_pressed
