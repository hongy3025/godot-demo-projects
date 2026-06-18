## 运动学角色控制器 —— 使用力和加速度驱动的物理角色。
## 继承自 CharacterBody2D，演示基本的水平移动、重力和跳跃。
extends CharacterBody2D

## 行走施加的力。
const WALK_FORCE = 600
## 最大行走速度。
const WALK_MAX_SPEED = 200
## 停止时的减速度。
const STOP_FORCE = 1300
## 跳跃速度（负值表示向上）。
const JUMP_SPEED = 200

## 从项目设置中获取默认重力值。
@onready var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))

func _physics_process(delta: float) -> void:
	# 水平移动：获取玩家输入方向
	var walk := WALK_FORCE * (Input.get_axis(&"move_left", &"move_right"))
	# 如果玩家没有尝试移动，减速停止
	if abs(walk) < WALK_FORCE * 0.2:
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	# 限制最大水平速度
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# 垂直移动：应用重力
	velocity.y += gravity * delta

	# 基于速度移动并处理碰撞
	move_and_slide()

	# 检测跳跃输入（必须在移动代码之后调用 is_on_floor()）
	if is_on_floor() and Input.is_action_just_pressed(&"jump"):
		velocity.y = -JUMP_SPEED
