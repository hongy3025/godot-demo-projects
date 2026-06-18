## 玩家角色节点 —— 骨骼动画演示的主角。
## 继承自 CharacterBody2D，使用 AnimationTree 驱动骨骼动画。
## 支持行走、奔跑、跳跃、下落、硬着陆、软着陆等多种动画状态。
class_name Player
extends CharacterBody2D

## 动画状态常量字典，必须与 AnimationTree 中的状态名称保持一致。
const States = {
	IDLE = "idle",
	WALK = "walk",
	RUN = "run",
	FLY = "fly",
	FALL = "fall",
}

## 行走速度（像素/秒）。
const WALK_SPEED = 200.0
## 加速度，用于平滑速度变化。值为行走速度的 6 倍。
const ACCELERATION_SPEED = WALK_SPEED * 6.0
## 跳跃初速度（负值表示向上）。
const JUMP_VELOCITY = -400.0
## 最大下落速度（终端速度），限制自由落体速度上限。
const TERMINAL_VELOCITY = 400

## 是否正在慢速下落（速度 > 300）。
var falling_slow: bool = false
## 是否正在快速下落（速度 >= 终端速度）。
var falling_fast: bool = false
## 硬着陆后禁止水平移动的剩余时间。
var no_move_horizontal_time := 0.0

## 从项目设置中获取默认重力值。
@onready var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
## 精灵节点引用。
@onready var sprite: Node2D = $Sprite2D
## 缓存精灵的原始 X 轴缩放，用于翻转时保持比例一致。
@onready var sprite_scale := sprite.scale.x


## 初始化时激活 AnimationTree。
func _ready() -> void:
	$AnimationTree.active = true


## 物理帧更新 —— 处理移动、跳跃、下落和动画状态切换。
func _physics_process(delta: float) -> void:
	var is_jumping: bool = false
	# 检测跳跃输入
	if Input.is_action_just_pressed(&"jump"):
		is_jumping = try_jump()
	elif Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		# 玩家提前松开跳跃键，减少垂直动量（短跳效果）
		velocity.y *= 0.6
	# 应用重力，限制最大下落速度
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	# 获取水平输入方向并计算目标速度
	var direction := Input.get_axis(&"move_left", &"move_right") * WALK_SPEED
	# 使用 move_toward 平滑加速/减速
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if no_move_horizontal_time > 0.0:
		# 硬着陆后短暂时间内禁止水平移动
		velocity.x = 0.0
		no_move_horizontal_time -= delta

	# 根据移动方向翻转精灵（通过缩放 X 轴实现）
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = 1.0 * sprite_scale
		else:
			sprite.scale.x = -1.0 * sprite_scale

	# 应用物理运动并处理碰撞
	move_and_slide()

	# 根据运动状态更新动画

	# 计算下落速度以决定动画
	if velocity.y >= TERMINAL_VELOCITY:
		falling_fast = true
		falling_slow = false
	elif velocity.y > 300:
		falling_slow = true

	# 触发跳跃动画（OneShot 节点）
	if is_jumping:
		$AnimationTree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	# 在地面时的动画状态切换
	if is_on_floor():
		# 硬着陆或软着陆动画
		if falling_fast:
			$AnimationTree["parameters/land_hard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			no_move_horizontal_time = 0.4
		elif falling_slow:
			$AnimationTree["parameters/land/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

		# 根据水平速度切换行走/奔跑/待机动画
		if abs(velocity.x) > 50:
			$AnimationTree["parameters/state/transition_request"] = States.RUN
			$AnimationTree["parameters/run_timescale/scale"] = abs(velocity.x) / 60
		elif velocity.x:
			$AnimationTree["parameters/state/transition_request"] = States.WALK
			$AnimationTree["parameters/walk_timescale/scale"] = abs(velocity.x) / 12
		else:
			$AnimationTree["parameters/state/transition_request"] = States.IDLE

		# 重置下落状态
		falling_fast = false
		falling_slow = false
	else:
		# 空中时根据垂直速度方向切换上升/下落动画
		if velocity.y > 0:
			$AnimationTree["parameters/state/transition_request"] = States.FALL
		else:
			$AnimationTree["parameters/state/transition_request"] = States.FLY


## 尝试跳跃。
## 仅在玩家在地面时执行跳跃。
## 返回: bool，是否成功执行跳跃。
func try_jump() -> bool:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		return true

	return false
