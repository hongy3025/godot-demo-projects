## 移动状态 —— 玩家在地面上行走/奔跑。
## 继承自 on_ground.gd，处理水平移动和碰撞检测。
extends "on_ground.gd"

## 最大行走速度。
@export var max_walk_speed := 450.0
## 最大奔跑速度。
@export var max_run_speed := 700.0

## 进入移动状态：初始化速度和方向，播放行走动画。
func enter() -> void:
	speed = 0.0
	velocity = Vector2()

	var input_direction := get_input_direction()
	update_look_direction(input_direction)
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.walk)


## 处理输入：委托给父类。
func handle_input(input_event: InputEvent) -> void:
	return super.handle_input(input_event)


## 每帧更新：根据输入方向和奔跑键控制移动。
func update(_delta: float) -> void:
	var input_direction := get_input_direction()
	if input_direction.is_zero_approx():
		finished.emit(PLAYER_STATE.idle)
	update_look_direction(input_direction)

	# 按住奔跑键时使用奔跑速度
	if Input.is_action_pressed(&"run"):
		speed = max_run_speed
	else:
		speed = max_walk_speed

	var collision_info := move(speed, input_direction)
	if not collision_info:
		return
	# 奔跑时撞到环境物体不触发特殊处理
	if speed == max_run_speed and collision_info.collider.is_in_group(&"environment"):
		return


## 执行物理移动。
## 参数 p_speed: 移动速度。
## 参数 direction: 移动方向。
## 返回: 碰撞信息（发生碰撞时），否则返回 null。
func move(p_speed: float, direction: Vector2) -> KinematicCollision2D:
	owner.velocity = direction.normalized() * p_speed
	owner.move_and_slide()
	if owner.get_slide_collision_count() == 0:
		return null

	return owner.get_slide_collision(0)
