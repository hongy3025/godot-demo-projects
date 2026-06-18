## 刚体控制器 —— 使用 RigidBody2D 实现角色控制。
## 演示如何在 RigidBody2D 上实现平台游戏角色的移动和跳跃。
extends RigidBody2D

var _initial_velocity := Vector2.ZERO
var _constant_velocity := Vector2.ZERO
var _motion_speed := 400.0
var _gravity_force := 50.0
var _jump_force := 1000.0
var _velocity := Vector2.ZERO
var _floor_max_angle := 45.0
var _on_floor: bool = false
var _jumping: bool = false
var _keep_velocity: bool = false

func _ready() -> void:
	gravity_scale = 0.0


func _physics_process(delta: float) -> void:
	if _initial_velocity != Vector2.ZERO:
		_velocity = _initial_velocity
		_initial_velocity = Vector2.ZERO
		_keep_velocity = true
	elif _constant_velocity != Vector2.ZERO:
		_velocity = _constant_velocity
	elif not _keep_velocity:
		_velocity.x = 0.0

	# 水平控制
	if Input.is_action_pressed(&"character_left"):
		if position.x > 0.0:
			_velocity.x = -_motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO
	elif Input.is_action_pressed(&"character_right"):
		if position.x < 1024.0:
			_velocity.x = _motion_speed
			_keep_velocity = false
			_constant_velocity = Vector2.ZERO

	# 跳跃和重力
	if is_on_floor():
		if not _jumping and Input.is_action_just_pressed(&"character_jump"):
			_jumping = true
			_velocity.y = -_jump_force
		elif not _jumping:
			_velocity.y = 0.0
	else:
		_velocity.y += _gravity_force * delta * 60.0
		_jumping = false

	linear_velocity = _velocity


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_on_floor = false

	var contacts := state.get_contact_count()
	for i in contacts:
		var normal := state.get_contact_local_normal(i)

		# 检测地面
		if acos(normal.dot(Vector2.UP)) <= deg_to_rad(_floor_max_angle) + 0.01:
			_on_floor = true

		# 检测天花板
		if acos(normal.dot(-Vector2.UP)) <= deg_to_rad(_floor_max_angle) + 0.01:
			_jumping = false
			_velocity.y = 0.0


func is_on_floor() -> bool:
	return _on_floor
