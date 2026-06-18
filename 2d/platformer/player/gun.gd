## 枪械节点 —— 生成并发射子弹的武器。
## Cooldown 计时器控制射击间隔。
class_name Gun
extends Marker2D

## 子弹速度。
const BULLET_VELOCITY = 850.0
## 子弹场景预加载。
const BULLET_SCENE = preload("res://player/bullet.tscn")

@onready var sound_shoot := $Shoot as AudioStreamPlayer2D
@onready var timer := $Cooldown as Timer


## 射击方法（仅由 Player.gd 调用）。
## 参数 direction: 射击方向（1 为右，-1 为左）。
## 返回: 是否成功发射。
func shoot(direction: float = 1.0) -> bool:
	if not timer.is_stopped():
		return false
	var bullet := BULLET_SCENE.instantiate() as Bullet
	bullet.global_position = global_position
	bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)

	bullet.set_as_top_level(true)
	add_child(bullet)
	sound_shoot.play()
	timer.start()
	return true
