## 暂停菜单 —— 管理游戏暂停、恢复和场景切换。
class_name PauseMenu
extends Control


## 淡入动画时长。
@export var fade_in_duration := 0.3
## 淡出动画时长。
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/ResumeButton") as Button
@onready var coins_counter := $ColorRect/CoinsCounter as CoinsCounter


func _ready() -> void:
	hide()


## 关闭暂停菜单：淡出动画后隐藏。
func close() -> void:
	var tween := create_tween()
	get_tree().paused = false
	tween.tween_property(
			self,
			^"modulate:a",
			0.0,
			fade_out_duration
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
			center_cont,
			^"anchor_bottom",
			0.5,
			fade_out_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)


## 打开暂停菜单：淡入动画显示。
func open() -> void:
	show()
	resume_button.grab_focus()

	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	var tween := create_tween()
	tween.tween_property(
			self,
			^"modulate:a",
			1.0,
			fade_in_duration
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
			center_cont,
			^"anchor_bottom",
			1.0,
			fade_out_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## 金币收集回调。
func _on_coin_collected() -> void:
	coins_counter.collect_coin()


## 继续按钮回调。
func _on_resume_button_pressed() -> void:
	close()


## 单人模式按钮回调。
func _on_singleplayer_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game_singleplayer.tscn")


## 分屏模式按钮回调。
func _on_splitscreen_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game_splitscreen.tscn")


## 退出按钮回调。
func _on_quit_button_pressed() -> void:
	if visible:
		get_tree().quit()
