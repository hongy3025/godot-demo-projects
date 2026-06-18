## 球体工厂 —— 点击鼠标生成球体实例。
## 继承自 Node2D，演示 PackedScene 的实例化。
extends Node2D


## 球体场景的 PackedScene。
@export var ball_scene: PackedScene = preload("res://ball.tscn")


## 处理鼠标点击输入，在点击位置生成球体。
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_echo():
		return

	if input_event is InputEventMouseButton and input_event.is_pressed():
		if input_event.button_index == MOUSE_BUTTON_LEFT:
			spawn(get_global_mouse_position())


## 在指定位置生成球体实例。
## 参数 spawn_global_position: 生成位置的全局坐标。
func spawn(spawn_global_position: Vector2) -> void:
	var instance: Node2D = ball_scene.instantiate()
	instance.global_position = spawn_global_position
	add_child(instance)
