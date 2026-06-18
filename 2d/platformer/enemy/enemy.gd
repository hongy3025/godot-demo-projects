## 平台游戏敌人 —— 使用 CharacterBody2D 的巡逻敌人。
## 在墙壁和悬崖边缘自动转向，可被子弹销毁。
class_name Enemy
extends CharacterBody2D

enum State {
	WALKING,
	DEAD,
}

const WALK_SPEED = 22.0

var _state := State.WALKING

@onready var gravity: int = ProjectSettings.get(&"physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _physics_process(delta: float) -> void:
	if _state == State.WALKING and velocity.is_zero_approx():
		velocity.x = WALK_SPEED
	velocity.y += gravity * delta
	# 检测悬崖边缘并转向
	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	# 撞墙转向
	if is_on_wall():
		velocity.x = -velocity.x

	move_and_slide()

	# 根据移动方向翻转精灵
	if velocity.x > 0.0:
		sprite.scale.x = 0.8
	elif velocity.x < 0.0:
		sprite.scale.x = -0.8

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


## 销毁敌人。
func destroy() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO


## 获取当前应播放的动画名称。
func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.WALKING:
		if velocity.x == 0:
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	else:
		animation_new = &"destroy"
	return animation_new
