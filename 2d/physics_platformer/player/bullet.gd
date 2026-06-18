## 子弹节点 —— 物理平台游戏的 RigidBody2D 子弹。
## 定时器超时后播放关闭动画。
class_name Bullet
extends RigidBody2D

## 是否已禁用（被击中后）。
var disabled: bool = false

func _ready() -> void:
	($Timer as Timer).start()


## 禁用子弹：播放关闭动画并标记为已禁用。
func disable() -> void:
	if disabled:
		return

	($AnimationPlayer as AnimationPlayer).play(&"shutdown")
	disabled = true
