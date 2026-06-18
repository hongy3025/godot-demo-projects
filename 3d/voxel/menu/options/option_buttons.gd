## 选项设置 UI 控制器 —— 管理渲染距离和雾效设置。
##
## 继承自 [Control]，从 Settings 单例读取/写入游戏设置。
extends Control

## 渲染距离显示标签。
@onready var render_distance_label: Label = $RenderDistanceLabel
## 渲染距离滑块。
@onready var render_distance_slider: Slider = $RenderDistanceSlider
## 雾效开关复选框。
@onready var fog_checkbox: CheckBox = $FogCheckBox


## _ready 入口。从 Settings 加载当前值并初始化 UI。
func _ready() -> void:
	render_distance_slider.value = Settings.render_distance
	render_distance_label.text = "渲染距离: " + String.num_int64(Settings.render_distance)
	fog_checkbox.button_pressed = Settings.fog_enabled


## 渲染距离滑块值变化回调。
##
## 参数:
##   value: 新的渲染距离值
func _on_RenderDistanceSlider_value_changed(value: float) -> void:
	Settings.render_distance = int(value)
	render_distance_label.text = "渲染距离: " + String.num_int64(Settings.render_distance)
	Settings.save_settings()


## 雾效开关回调。
func _on_FogCheckBox_pressed() -> void:
	Settings.fog_enabled = fog_checkbox.button_pressed
	Settings.save_settings()
