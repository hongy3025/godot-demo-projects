## FPS 示例玩家控制器 —— 第一人称射击角色。
##
## 继承自 [CharacterBody3D]，实现完整的 FPS 控制：
## - WASD 移动、冲刺、跳跃
## - 鼠标视角、瞄准（右键）、射击（左键）
## - 身体倾斜（Q/E）
## - 子弹发射
extends CharacterBody3D

# 行走参数。
const norm_grav = -38.8
const MAX_SPEED = 22
const JUMP_SPEED = 26
const ACCEL = 8.5
# 冲刺参数。
const MAX_SPRINT_SPEED = 34
const SPRINT_ACCEL = 18
# 减速度和最大可攀爬坡度。
const DEACCEL = 28
const MAX_SLOPE_ANGLE = 40
# 子弹发射参数。
const LEFT_MOUSE_FIRE_TIME = 0.15
const BULLET_SPEED = 100

## 当前速度向量。
var vel = Vector3()
## 玩家意图移动的方向向量。
var dir = Vector3()
## 是否正在冲刺。
var is_sprinting = false

## 鼠标灵敏度（可能需要根据个人习惯调整）。
var MOUSE_SENSITIVITY = 0.08

## 跳跃按钮是否按下。
var jump_button_down = false

## 当前倾斜值（在倾斜轨道上的位置）。
var lean_value = 0.5

## 右键是否按下。
var right_mouse_down = false
## 左键射击计时器。
var left_mouse_timer = 0

## 是否可以切换动画。
var anim_done = true
## 当前动画名称。
var current_anim = "Starter"

## 简单子弹场景预加载。
var simple_bullet = preload("res://fps/simple_bullet.tscn")

## 摄像机支架节点，用于控制 Y 轴旋转。
@onready var camera_holder = $CameraHolder
## 实际摄像机节点。
@onready var camera = $CameraHolder/LeanPath/PathFollow3D/IK_LookAt_Chest/Camera3D
## 路径跟随节点，用于倾斜效果。
@onready var path_follow_node = $CameraHolder/LeanPath/PathFollow3D
## 动画播放器，用于瞄准动画。
@onready var anim_player = $CameraHolder/AnimationPlayer
## 手枪枪口端点，用于子弹发射位置。
@onready var pistol_end = $CameraHolder/Weapon/Pistol/PistolEnd


## _ready 入口。连接动画完成信号并捕获鼠标。
func _ready():
	anim_player.animation_finished.connect(animation_finished)

	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)


## _physics_process 入口。每物理帧处理输入和移动。
##
## 参数:
##   delta: 物理帧时间间隔
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)


## 处理输入。包括移动方向、瞄准、射击、冲刺、跳跃和倾斜。
##
## 参数:
##   delta: 帧时间间隔
func process_input(delta):
	# 重置方向向量。
	dir = Vector3()
	# 获取摄像机的全局变换以使用其方向向量。
	var cam_xform = camera.get_global_transform()

	# 行走方向
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		dir += -cam_xform.basis[2]
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		dir += cam_xform.basis[2]
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		dir += -cam_xform.basis[0]
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir += cam_xform.basis[0]

	if Input.is_action_just_pressed(&"ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# 右键瞄准。
	if Input.is_mouse_button_pressed(2):
		if not right_mouse_down:
			right_mouse_down = true

			if anim_done:
				if current_anim != "Aiming":
					anim_player.play(&"Aiming")
					current_anim = "Aiming"
				else:
					anim_player.play(&"Idle")
					current_anim = "Idle"

				anim_done = false
	else:
		right_mouse_down = false

	# 左键射击。
	if Input.is_mouse_button_pressed(1):
		if left_mouse_timer <= 0:
			left_mouse_timer = LEFT_MOUSE_FIRE_TIME

			# 创建子弹。
			var new_bullet = simple_bullet.instantiate()
			get_tree().root.add_child(new_bullet)
			new_bullet.global_transform = pistol_end.global_transform
			new_bullet.linear_velocity = new_bullet.global_transform.basis.z * BULLET_SPEED
	if left_mouse_timer > 0:
		left_mouse_timer -= delta

	# 冲刺。
	if Input.is_key_pressed(KEY_SHIFT):
		is_sprinting = true
	else:
		is_sprinting = false

	# 跳跃。
	if Input.is_key_pressed(KEY_SPACE):
		if not jump_button_down:
			jump_button_down = true
			if is_on_floor():
				vel.y = JUMP_SPEED
	else:
		jump_button_down = false

	# 身体倾斜。
	if Input.is_key_pressed(KEY_Q):
		lean_value += 1.2 * delta
	elif Input.is_key_pressed(KEY_E):
		lean_value -= 1.2 * delta
	else:
		if lean_value > 0.5:
			lean_value -= 1 * delta
			if lean_value < 0.5:
				lean_value = 0.5
		elif lean_value < 0.5:
			lean_value += 1 * delta
			if lean_value > 0.5:
				lean_value = 0.5

	lean_value = clamp(lean_value, 0, 1)
	path_follow_node.h_offset = lean_value
	if lean_value < 0.5:
		var lerp_value = lean_value * 2
		path_follow_node.rotation_degrees.z = (20 * (1 - lerp_value))
	else:
		var lerp_value = (lean_value - 0.5) * 2
		path_follow_node.rotation_degrees.z = (-20 * lerp_value)


## 处理角色移动。应用重力、加速/减速并执行移动。
##
## 参数:
##   delta: 帧时间间隔
func process_movement(delta):
	var grav = norm_grav

	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * grav

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if not is_sprinting:
			accel = ACCEL
		else:
			accel = SPRINT_ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.lerp(target, accel * delta)

	vel.x = hvel.x
	vel.z = hvel.z

	velocity = vel
	move_and_slide()


## 鼠标视角控制。
##
## 参数:
##   event: 输入事件对象
##
## 使用鼠标相对运动旋转角色和摄像机支架。
## 摄像机俯仰限制在 -40 到 60 度之间。
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(event.screen_relative.x * MOUSE_SENSITIVITY * -1))
		camera_holder.rotate_x(deg_to_rad(event.screen_relative.y * MOUSE_SENSITIVITY))

		# 限制摄像机旋转角度，防止上下颠倒。
		var camera_rot = camera_holder.rotation_degrees
		if camera_rot.x < -40:
			camera_rot.x = -40
		elif camera_rot.x > 60:
			camera_rot.x = 60

		camera_holder.rotation_degrees = camera_rot

	else:
		pass


## 动画播放完成回调。标记动画状态为可切换。
func animation_finished(_anim):
	anim_done = true
