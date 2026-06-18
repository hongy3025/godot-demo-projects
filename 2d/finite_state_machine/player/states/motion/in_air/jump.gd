## 跳跃状态 —— 玩家在空中时的运动逻辑。
## 继承自 motion.gd，实现空中水平移动和跳跃高度动画。
extends "../motion.gd"

## 空中最大水平速度基准值。
@export var base_max_horizontal_speed := 400.0

## 空中加速度。
@export var air_acceleration := 1000.0
## 空中减速度。
@export var air_deceleration := 2000.0
## 空中转向力，控制方向改变的灵敏度。
@export var air_steering_power := 50.0

## 重力加速度。
@export var gravity := 1600.0

## 进入跳跃时的初始速度。
var enter_velocity := Vector2()

## 当前最大水平速度。
var max_horizontal_speed := 0.0
## 当前水平速度大小。
var horizontal_speed := 0.0
## 当前水平速度向量。
var horizontal_velocity := Vector2()

## 当前垂直速度大小。
var vertical_speed := 0.0
## 当前跳跃高度。
var height := 0.0

## 初始化跳跃参数。
## 参数 speed: 进入跳跃时的水平速度。
## 参数 velocity: 进入跳跃时的速度向量。
func initialize(speed: float, velocity: Vector2) -> void:
	horizontal_speed = speed
	if speed > 0.0:
		max_horizontal_speed = speed
	else:
		max_horizontal_speed = base_max_horizontal_speed
	enter_velocity = velocity


## 进入跳跃状态：设置初始速度和动画。
func enter() -> void:
	var input_direction := get_input_direction()
	update_look_direction(input_direction)

	if input_direction:
		horizontal_velocity = enter_velocity
	else:
		horizontal_velocity = Vector2()
	vertical_speed = 600.0

	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.idle)


## 每帧更新：处理空中水平移动和跳跃高度变化。
func update(delta: float) -> void:
	var input_direction := get_input_direction()
	update_look_direction(input_direction)

	move_horizontally(delta, input_direction)
	animate_jump_height(delta)
	# 落地时切换到上一个状态
	if height <= 0.0:
		finished.emit(PLAYER_STATE.previous)


## 空中水平移动：加速/减速和转向控制。
## 参数 delta: 帧时间。
## 参数 direction: 输入方向。
func move_horizontally(delta: float, direction: Vector2) -> void:
	if direction:
		horizontal_speed += air_acceleration * delta
	else:
		horizontal_speed -= air_deceleration * delta
	horizontal_speed = clamp(horizontal_speed, 0, max_horizontal_speed)

	# 计算目标速度与当前速度的差值，施加转向力
	var target_velocity := horizontal_speed * direction.normalized()
	var steering_velocity := (target_velocity - horizontal_velocity).normalized() * air_steering_power
	horizontal_velocity += steering_velocity

	owner.velocity = horizontal_velocity
	owner.move_and_slide()


## 模拟跳跃高度动画：通过 BodyPivot 的 Y 轴偏移实现。
## 参数 delta: 帧时间。
func animate_jump_height(delta: float) -> void:
	vertical_speed -= gravity * delta
	height += vertical_speed * delta
	height = max(0.0, height)

	owner.get_node(^"BodyPivot").position.y = -height
