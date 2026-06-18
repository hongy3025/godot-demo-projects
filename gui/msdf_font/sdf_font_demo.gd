## MSDF 字体演示 —— 展示 Godot 的多通道有符号距离场（MSDF）字体渲染。
## 继承自 [Control]，演示在传统字体和 MSDF 字体之间切换，以及调整轮廓大小。
extends Control


## 输入事件处理：检测 MSDF 字体切换按键。
## 按 toggle_msdf_font 动作键时，在传统字体和 MSDF 字体之间切换。
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_msdf_font"):
		if %FontLabel.get_theme_font(&"font").multichannel_signed_distance_field:
			%FontLabel.add_theme_font_override(&"font", preload("res://montserrat_semibold.ttf"))
		else:
			%FontLabel.add_theme_font_override(&"font", preload("res://montserrat_semibold_msdf.ttf"))

		update_label()


## 更新标签文本，显示当前字体渲染模式（MSDF 或 Traditional）。
func update_label() -> void:
	%FontMode.text = "Font rendering: %s" % (
			"MSDF" if %FontLabel.get_theme_font(&"font").multichannel_signed_distance_field else "Traditional"
		)


## 轮廓大小滑块值变化回调：更新字体轮廓大小。
func _on_outline_size_value_changed(value: float) -> void:
	%FontLabel.add_theme_constant_override(&"outline_size", int(value))
	%Value.text = str(value)
