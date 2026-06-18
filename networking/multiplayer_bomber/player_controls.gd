## 玩家输入控制器 —— 处理键盘输入并转换为运动指令。
##
## 继承自 [Node]，作为玩家节点的子节点。
## 使用 @export 暴露 motion 和 bombing 属性，以便网络同步。
## motion 属性通过 setter 进行值范围限制，防止玩家发送非法值。
extends Node

## 玩家运动方向向量，范围限制在 [-1, 1] 之间。
@export var motion := Vector2():
	set(value):
		# 该值由玩家发送，确保值在合理范围内。
		motion = clamp(value, Vector2(-1, -1), Vector2(1, 1))

## 是否正在放置炸弹。
@export var bombing: bool = false


## 更新输入状态：读取键盘按键并设置 motion 和 bombing。
func update() -> void:
	var m := Vector2()
	if Input.is_action_pressed(&"move_left"):
		m += Vector2(-1, 0)
	if Input.is_action_pressed(&"move_right"):
		m += Vector2(1, 0)
	if Input.is_action_pressed(&"move_up"):
		m += Vector2(0, -1)
	if Input.is_action_pressed(&"move_down"):
		m += Vector2(0, 1)

	motion = m
	bombing = Input.is_action_pressed(&"set_bomb")
