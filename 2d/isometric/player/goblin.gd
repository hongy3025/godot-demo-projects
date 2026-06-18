## 哥布林角色 —— 等距视角下的 8 方向行走角色。
## 继承自 CharacterBody2D，根据移动方向自动切换 8 个方向的动画。
extends CharacterBody2D

## 移动速度（像素/秒）。
const MOTION_SPEED = 160

## 上一次移动方向，用于在停止时保持朝向。
var last_direction = Vector2(1, 0)

## 动画方向映射表，将 8 个方向映射到对应的动画名称和水平翻转。
var anim_directions = {
	"idle": [
		["side_right_idle", false],
		["45front_right_idle", false],
		["front_idle", false],
		["45front_left_idle", false],
		["side_left_idle", false],
		["45back_left_idle", false],
		["back_idle", false],
		["45back_right_idle", false],
	],

	"walk": [
		["side_right_walk", false],
		["45front_right_walk", false],
		["front_walk", false],
		["45front_left_walk", false],
		["side_left_walk", false],
		["45back_left_walk", false],
		["back_walk", false],
		["45back_right_walk", false],
	],
}


func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left")
	motion.y = Input.get_action_strength(&"move_down") - Input.get_action_strength(&"move_up")
	# 等距视角下 Y 轴移动速度减半以匹配视觉比例
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	set_velocity(motion)
	move_and_slide()
	var dir = velocity

	if dir.length() > 0:
		last_direction = dir
		update_animation("walk")
	else:
		update_animation("idle")


## 根据移动方向更新动画。
## 将方向向量转换为角度，映射到 8 个方向之一。
## 参数 anim_set: 动画集名称（"idle" 或 "walk"）。
func update_animation(anim_set):
	var angle = rad_to_deg(last_direction.angle()) + 22.5
	var slice_dir = floor(angle / 45)

	$Sprite2D.play(anim_directions[anim_set][slice_dir][0])
	$Sprite2D.flip_h = anim_directions[anim_set][slice_dir][1]
