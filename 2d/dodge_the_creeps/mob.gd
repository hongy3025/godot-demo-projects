## 怪物节点 —— 自动移动的 RigidBody2D 敌人。
## 随机选择外观动画，超出屏幕时自动销毁。
extends RigidBody2D

func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()


## 离开屏幕时自动销毁。
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
