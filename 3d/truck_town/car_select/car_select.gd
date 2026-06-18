## 车辆选择界面控制器 —— 管理车辆选择、氛围设置和场景加载。
##
## 继承自 [Control]，提供车辆选择、氛围模式、SDFGI 开关、
## 音量控制和加载画面功能。
extends Control

## 音频主总线索引。
var audio_master: int = AudioServer.get_bus_index("Master")

## 车辆选择容器。
@onready var car_container: HBoxContainer = %CarContainer

## 日出氛围复选框。
@onready var button_sunrise: CheckBox = %Sunrise
## 白天氛围复选框。
@onready var button_day: CheckBox = %Day
## 日落氛围复选框。
@onready var button_sunset: CheckBox = %Sunset
## 夜晚氛围复选框。
@onready var button_night: CheckBox = %Night

## SDFGI 开关复选框。
@onready var button_sdfgi: CheckBox = $%SDFGI
## 静音按钮。
@onready var button_mute: TextureButton = %Mute
## 音量滑块。
@onready var slider_volume: HSlider = %Volume

## 加载画面面板。
@onready var loading_screen: PanelContainer = %LoadingPanel

## 当前加载的小镇场景。
var town: Node3D = null

## _ready 入口。初始化焦点、音量和 SDFGI 可见性。
func _ready() -> void:
	# 自动聚焦第一个车辆（手柄可访问性）。
	focus_first_car()

	# 初始化音量滑块。
	slider_volume.value = AudioServer.get_bus_volume_linear(audio_master)

	# 在不支持 SDFGI 的渲染器上隐藏按钮。
	button_sdfgi.visible = RenderingServer.get_current_rendering_method() == "forward_plus"


## _process 入口。处理返回键。
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"back"):
		_on_back_pressed()


## 聚焦第一个车辆按钮。
func focus_first_car() -> void:
	car_container.get_child(0).grab_focus.call_deferred()


## 加载场景。显示加载画面，实例化车辆和小镇场景。
##
## 参数:
##   car_scene: 车辆场景
func _load_scene(car_scene: PackedScene) -> void:
	# 显示加载画面并等待渲染。
	loading_screen.visible = true
	await RenderingServer.frame_post_draw

	var car: Node3D = car_scene.instantiate()
	car.name = "car"
	town = preload("res://town/town_scene.tscn").instantiate()

	if button_sunrise.button_pressed:
		town.mood = town.Mood.SUNRISE
	elif button_day.button_pressed:
		town.mood = town.Mood.DAY
	elif button_sunset.button_pressed:
		town.mood = town.Mood.SUNSET
	elif button_night.button_pressed:
		town.mood = town.Mood.NIGHT

	town.setup(car, _on_back_pressed, button_sdfgi.button_pressed)

	get_parent().add_child(town)
	hide()


## 返回按钮回调。从小镇返回主菜单或退出游戏。
func _on_back_pressed() -> void:
	if is_instance_valid(town):
		town.queue_free()
		loading_screen.visible = false
		show()
		focus_first_car()
	else:
		get_tree().quit()


## 小型货车选择回调。
func _on_mini_van_pressed() -> void:
	_load_scene(preload("res://vehicles/car_base.tscn"))


## 拖挂卡车选择回调。
func _on_trailer_truck_pressed() -> void:
	_load_scene(preload("res://vehicles/trailer_truck.tscn"))


## 拖车选择回调。
func _on_tow_truck_pressed() -> void:
	_load_scene(preload("res://vehicles/tow_truck.tscn"))


## 静音切换回调。
##
## 参数:
##   muted: 是否静音
func _on_mute_toggled(muted: bool) -> void:
	AudioServer.set_bus_mute(audio_master, muted)


## 音量滑块值变化回调。
##
## 参数:
##   value: 音量值（线性）
func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(audio_master, value)
