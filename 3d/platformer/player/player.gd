## 平台游戏玩家角色 —— 第三人称 3D 平台游戏主角。
##
## 继承自 [CharacterBody3D]，实现完整的平台游戏控制：
## - WASD 移动（基于摄像机方向）
## - 跳跃（可释放跳跃键降低跳跃高度）
## - 射击
## - 金币收集
## - 动画混合（行走/奔跑/空中/射击）
class_name Player
extends CharacterBody3D

## 动画状态枚举。
enum _Anim {
	FLOOR,  ## 地面状态
	AIR,    ## 空中状态
}

## 射击动画持续时间。
const SHOOT_TIME: float = 1.5
## 射击缩放系数。
const SHOOT_SCALE: float = 2.0
## 角色模型缩放。
const CHAR_SCALE := Vector3(0.3, 0.3, 0.3)
## 最大移动速度。
const MAX_SPEED: float = 6.0
## 转向速度。
const TURN_SPEED: float = 40.0
## 跳跃速度。
const JUMP_VELOCITY: float = 12.5
## 子弹速度。
const BULLET_SPEED: float = 20.0
## 空中是否减速。
const AIR_IDLE_DEACCEL: bool = false
## 加速度。
const ACCEL: float = 14.0
## 减速度。
const DEACCEL: float = 14.0
## 空中加速度系数。
const AIR_ACCEL_FACTOR: float = 0.5
## 急转弯角度阈值。
const SHARP_TURN_THRESHOLD: float = deg_to_rad(140.0)

## 移动方向向量。
var movement_dir := Vector3()
## 是否正在跳跃。
var jumping: bool = false
## 上一帧是否在射击。
var prev_shoot: bool = false
## 射击动画混合值。
var shoot_blend: float = 0.0

## 收集的金币数量。
var coins: int = 0

## 初始位置，用于重置。
@onready var initial_position := position
## 重力向量（从项目设置读取）。
@onready var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")

## 摄像机节点引用。
@onready var _camera := $Target/Camera3D as Camera3D
## 动画树节点引用。
@onready var _animation_tree := $AnimationTree as AnimationTree


## _physics_process 入口。每物理帧处理移动、跳跃、射击和动画。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 处理位置重置和金币显示
## 2. 应用重力
## 3. 读取 WASD 输入并转换为摄像机相对方向
## 4. 地面移动：加速/减速/转向/急转弯检测
## 5. 空中移动：较低加速度/可释放跳跃键降低跳跃高度
## 6. 射击：创建子弹实例
## 7. 更新动画树参数
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"reset_position") or global_position.y < -12:
		# 玩家按下重置键或掉落出地图。
		position = initial_position
		velocity = Vector3.ZERO
		# 传送玩家后重置物理插值。
		reset_physics_interpolation()

	# 更新金币数量及其"视差"副本。
	# 使用多个 Label3D 副本实现伪 3D 效果。
	%CoinCount.text = str(coins)
	%CoinCount.get_node(^"Parallax").text = str(coins)
	%CoinCount.get_node(^"Parallax2").text = str(coins)
	%CoinCount.get_node(^"Parallax3").text = str(coins)
	%CoinCount.get_node(^"Parallax4").text = str(coins)

	velocity += gravity * delta

	var anim := _Anim.FLOOR

	var vertical_velocity := velocity.y
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)

	var horizontal_direction := horizontal_velocity.normalized()
	var horizontal_speed := horizontal_velocity.length()

	# 玩家输入。
	var cam_basis := _camera.get_global_transform().basis
	var movement_vec2 := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var movement_direction := cam_basis * Vector3(movement_vec2.x, 0, movement_vec2.y)
	movement_direction.y = 0
	movement_direction = movement_direction.normalized()

	var jump_attempt := Input.is_action_pressed(&"jump")

	if is_on_floor():
		var sharp_turn := horizontal_speed > 0.1 and \
				acos(movement_direction.dot(horizontal_direction)) > SHARP_TURN_THRESHOLD

		if movement_direction.length() > 0.1 and not sharp_turn:
			if horizontal_speed > 0.001:
				horizontal_direction = adjust_facing(
						horizontal_direction,
						movement_direction,
						delta,
						1.0 / horizontal_speed * TURN_SPEED,
						Vector3.UP
					)
			else:
				horizontal_direction = movement_direction

			if horizontal_speed < MAX_SPEED:
				horizontal_speed += ACCEL * delta
		else:
			horizontal_speed -= DEACCEL * delta
			if horizontal_speed < 0:
				horizontal_speed = 0

		horizontal_velocity = horizontal_direction * horizontal_speed

		var mesh_xform := ($Player/Skeleton as Node3D).get_transform()
		var facing_mesh := -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - Vector3.UP * facing_mesh.dot(Vector3.UP)).normalized()

		if horizontal_speed > 0:
			facing_mesh = adjust_facing(
					facing_mesh,
					movement_direction,
					delta,
					1.0 / horizontal_speed * TURN_SPEED,
					Vector3.UP
				)
		var m3 := Basis(
				-facing_mesh,
				Vector3.UP,
				-facing_mesh.cross(Vector3.UP).normalized()
			).scaled(CHAR_SCALE)

		$Player/Skeleton.set_transform(Transform3D(m3, mesh_xform.origin))

		if not jumping and jump_attempt:
			vertical_velocity = JUMP_VELOCITY
			jumping = true
			$SoundJump.play()

	else:
		anim = _Anim.AIR

		if movement_direction.length() > 0.1:
			horizontal_velocity += movement_direction * (ACCEL * AIR_ACCEL_FACTOR * delta)
			if horizontal_velocity.length() > MAX_SPEED:
				horizontal_velocity = horizontal_velocity.normalized() * MAX_SPEED
		elif AIR_IDLE_DEACCEL:
			horizontal_speed = horizontal_speed - (DEACCEL * AIR_ACCEL_FACTOR * delta)
			if horizontal_speed < 0:
				horizontal_speed = 0
			horizontal_velocity = horizontal_direction * horizontal_speed

		if Input.is_action_just_released(&"jump") and velocity.y > 0.0:
			# 在到达最高点前释放跳跃键可降低跳跃高度。
			vertical_velocity *= 0.7

	if jumping and vertical_velocity < 0:
		jumping = false

	velocity = horizontal_velocity + Vector3.UP * vertical_velocity

	if is_on_floor():
		movement_dir = velocity

	move_and_slide()

	if shoot_blend > 0:
		shoot_blend *= 0.97
		if (shoot_blend < 0):
			shoot_blend = 0
	var shoot_attempt := Input.is_action_pressed(&"shoot")
	if shoot_attempt and not prev_shoot:
		shoot_blend = SHOOT_TIME
		var bullet := preload("res://player/bullet/bullet.tscn").instantiate() as Bullet
		bullet.set_transform($Player/Skeleton/Bullet.get_global_transform().orthonormalized())
		get_parent().add_child(bullet)
		bullet.set_linear_velocity(
				$Player/Skeleton/Bullet.get_global_transform().basis[2].normalized() * BULLET_SPEED
			)
		bullet.add_collision_exception_with(self)
		$SoundShoot.play()

	prev_shoot = shoot_attempt

	if is_on_floor():
		# 玩家在"空闲"和"行走/奔跑"动画之间的混合量。
		_animation_tree[&"parameters/run/blend_amount"] = horizontal_speed / MAX_SPEED

		# 玩家奔跑程度（相对于行走）。0.0=完全行走，1.0=完全奔跑。
		_animation_tree[&"parameters/speed/blend_amount"] = minf(1.0, horizontal_speed / (MAX_SPEED * 0.5))

	_animation_tree[&"parameters/state/blend_amount"] = anim
	_animation_tree[&"parameters/air_dir/blend_amount"] = clampf(-velocity.y / 4 + 0.5, 0, 1)
	_animation_tree[&"parameters/gun/blend_amount"] = minf(shoot_blend, 1.0)


## 平滑调整朝向。将 facing 向量逐步转向 target 向量。
##
## 参数:
##   facing: 当前朝向向量
##   target: 目标朝向向量
##   step: 时间步长
##   adjust_rate: 调整速率
##   current_gn: 当前上方向
##
## 返回: [Vector3] 调整后的朝向向量
func adjust_facing(facing: Vector3, target: Vector3, step: float, adjust_rate: float, \
		current_gn: Vector3) -> Vector3:
	var normal := target
	var t := normal.cross(current_gn).normalized()

	var x := normal.dot(facing)
	var y := t.dot(facing)

	var ang := atan2(y,x)

	if absf(ang) < 0.001:
		return facing

	var s := signf(ang)
	ang = ang * s
	var turn := ang * adjust_rate * step
	var a: float
	if ang < turn:
		a = ang
	else:
		a = turn
	ang = (ang - a) * s

	return (normal * cos(ang) + t * sin(ang)) * facing.length()
