## 子弹生成器 —— 按冷却时间生成子弹。
## 继承自 Node2D，根据玩家朝向发射子弹。
extends Node2D

## 子弹场景的预加载资源。
var bullet := preload("Bullet.tscn")

## 处理开火输入。
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"fire"):
		fire()


## 发射子弹：冷却中则忽略，否则创建新子弹并设置方向和位置。
func fire() -> void:
	if not $CooldownTimer.is_stopped():
		return

	$CooldownTimer.start()
	var new_bullet := bullet.instantiate()
	new_bullet.position = global_position
	new_bullet.direction = owner.look_direction
	add_child(new_bullet)
