## 平台游戏子弹 —— 击中敌人后播放销毁动画的 RigidBody2D。
class_name Bullet
extends RigidBody2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer


## 销毁子弹：播放销毁动画。
func destroy() -> void:
	animation_player.play(&"destroy")


## 碰撞体进入回调：击中敌人时销毁敌人。
func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		(body as Enemy).destroy()
