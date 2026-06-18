## 金币节点 —— 玩家触碰后播放拾取动画。
class_name Coin
extends Area2D

## 是否已被拾取。
var taken: bool = false

func _on_body_enter(body: Node2D) -> void:
	if not taken and body is Player:
		($AnimationPlayer as AnimationPlayer).play(&"taken")
