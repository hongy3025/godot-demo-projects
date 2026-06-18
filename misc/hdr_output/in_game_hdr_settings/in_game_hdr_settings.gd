## HDR 运行时设置面板 —— 在游戏中调整 HDR 输出参数。
##
## 继承自 [Control]，提供 HDR 开关、参考亮度、最大亮度等参数的实时调节。
## 设置会保存到用户配置文件，下次启动时自动恢复。
extends Control

## HDR 设置文件路径
const HDR_SETTINGS_FILE = "user://hdr_settings.cfg"
## HDR 设置 INI 节名称
const HDR_SETTINGS_SECTION = "HDR"


## 是否自动调整参考亮度
var _auto_adjust_reference: bool = true
## 是否自动调整最大亮度
var _auto_adjust_max: bool = true


## 可见性变化回调，可见时启用处理，隐藏时禁用。
func _on_visibility_changed() -> void:
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


## _ready 入口，从配置文件加载 HDR 设置。
func _ready() -> void:
	var window: Window = get_window()
	var window_id = window.get_window_id()
	var hdr_settings: ConfigFile = ConfigFile.new()
	if hdr_settings.load(HDR_SETTINGS_FILE) == OK:
		window.hdr_output_requested = hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_requested", window.hdr_output_requested)
		if overriding_reference_luminance_supported():
			DisplayServer.window_set_hdr_output_reference_luminance(hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_reference_luminance", DisplayServer.window_get_hdr_output_reference_luminance(window_id)), window_id)
		if overriding_max_luminance_supported():
			DisplayServer.window_set_hdr_output_max_luminance(hdr_settings.get_value(HDR_SETTINGS_SECTION, "hdr_output_max_luminance", DisplayServer.window_get_hdr_output_max_luminance(window_id)), window_id)

	_auto_adjust_reference = DisplayServer.window_get_hdr_output_reference_luminance(window_id) < 0
	_auto_adjust_max = DisplayServer.window_get_hdr_output_max_luminance(window_id) < 0

	%BrightnessDisplay.visible = overriding_reference_luminance_supported()
	%BrightnessAdjustment.visible = overriding_reference_luminance_supported()
	%MaxLumDisplay.visible = overriding_max_luminance_supported()
	%MaxLumAdjustment.visible = overriding_max_luminance_supported()


## 保存当前 HDR 设置到配置文件。
func save_settings() -> void:
	var window: Window = get_window()
	var window_id = window.get_window_id()
	var hdr_settings: ConfigFile = ConfigFile.new()
	hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_requested", window.hdr_output_requested)
	if window.hdr_output_requested:
		hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_reference_luminance", DisplayServer.window_get_hdr_output_reference_luminance(window_id))
		hdr_settings.set_value(HDR_SETTINGS_SECTION, "hdr_output_max_luminance", DisplayServer.window_get_hdr_output_max_luminance(window_id))
	hdr_settings.save(HDR_SETTINGS_FILE)


## 清除已保存的 HDR 设置。
func erase_settings() -> void:
	var hdr_settings: ConfigFile = ConfigFile.new()
	if hdr_settings.load(HDR_SETTINGS_FILE) == OK:
		hdr_settings.erase_section(HDR_SETTINGS_SECTION)
		hdr_settings.save(HDR_SETTINGS_FILE)


## 检测当前平台是否支持覆盖参考亮度（仅 Windows）。
func overriding_reference_luminance_supported() -> bool:
	return DisplayServer.get_name() == &"Windows"


## 检测当前平台是否支持覆盖最大亮度（Windows/macOS/嵌入式 macOS）。
func overriding_max_luminance_supported() -> bool:
	var display_server_name = DisplayServer.get_name()
	return display_server_name == &"Windows" \
			or display_server_name == &"macOS" \
			or (display_server_name == &"embedded" and OS.get_name() == &"macOS")


## _process 入口，每帧更新 HDR 状态显示。
func _process(_delta: float) -> void:
	var window_id = get_window().get_window_id()
	var hdr_supported := DisplayServer.window_is_hdr_output_supported(window_id)
	%HDRCheckButton.disabled = not hdr_supported

	var hdr_output_enabled: bool = DisplayServer.window_is_hdr_output_enabled(window_id)
	if %HDRCheckButton.button_pressed != hdr_output_enabled:
		%HDRCheckButton.button_pressed = hdr_output_enabled
	%HDROptions.visible = hdr_output_enabled and hdr_supported

	%BrightnessSlider.max_value = DisplayServer.window_get_hdr_output_current_max_luminance()
	%BrightnessSlider.value = DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)
	%BrightnessLabel.text = "%0.0f" % DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)

	$%MaxLumSlider.min_value = DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)
	%MaxLumSlider.value = DisplayServer.window_get_hdr_output_current_max_luminance()
	%MaxLumLabel.text = "%0.0f" % DisplayServer.window_get_hdr_output_current_max_luminance()

	%ResetBrightness.disabled = DisplayServer.window_get_hdr_output_reference_luminance(window_id) < 0
	%ResetMaxLum.disabled = DisplayServer.window_get_hdr_output_max_luminance(window_id) < 0


## HDR 复选框切换回调。
func _on_hdr_check_button_toggled(toggled_on: bool) -> void:
	# 向显示器请求 HDR 输出
	if not %HDRCheckButton.disabled:
		get_window().hdr_output_requested = toggled_on


## 亮度滑块值变化回调。
func _on_brightness_slider_value_changed(value: float) -> void:
	if not _auto_adjust_reference:
		var window_id = get_window().get_window_id()
		DisplayServer.window_set_hdr_output_reference_luminance(value, window_id)


## 最大亮度滑块值变化回调。
func _on_max_lum_slider_value_changed(value: float) -> void:
	if not _auto_adjust_max:
		var window_id = get_window().get_window_id()
		DisplayServer.window_set_hdr_output_max_luminance(value, window_id)


## 重置亮度按钮回调。
func _on_reset_brightness_pressed() -> void:
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_hdr_output_reference_luminance(-1, window_id)
	_auto_adjust_reference = true


## 重置最大亮度按钮回调。
func _on_reset_max_lum_pressed() -> void:
	var window_id = get_window().get_window_id()
	DisplayServer.window_set_hdr_output_max_luminance(-1, window_id)
	_auto_adjust_max = true


## 亮度滑块开始拖拽回调。
func _on_brightness_slider_drag_started() -> void:
	_auto_adjust_reference = false


## 最大亮度滑块开始拖拽回调。
func _on_max_lum_slider_drag_started() -> void:
	_auto_adjust_max = false
