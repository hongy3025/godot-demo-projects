## 玩家角色 —— 第三人称跳跃踩怪游戏的主角。
##
## 继承自 [CharacterBody3D]，实现移动、跳跃、踩怪弹跳和碰撞检测。
extends CharacterBody3D

## 玩家被击中时发出的信号。
signal hit

## 玩家移动速度（米/秒）。
@export var speed = 14
## 跳跃冲量（米/秒）。
@export var jump_impulse = 20
## 踩到怪物后的弹跳冲量（米/秒）。
@export var bounce_impulse = 16
## 空中下落加速度（米/秒²）。
@export var fall_acceleration = 75


## _physics_process 入口。每物理帧处理移动、跳跃和踩怪检测。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 读取 WASD 输入并计算移动方向
## 2. 根据移动方向旋转角色
## 3. 应用跳跃和重力
## 4. 检测是否踩到怪物（通过碰撞法线判断）
## 5. 根据跳跃高度调整角色 X 轴旋转（跳跃弧线效果）
func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed(&"move_right"):
		direction.x += 1
	if Input.is_action_pressed(&"move_left"):
		direction.x -= 1
	if Input.is_action_pressed(&"move_back"):
		direction.z += 1
	if Input.is_action_pressed(&"move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# 设置角色朝向移动方向。
		basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# 跳跃。
	if is_on_floor() and Input.is_action_just_pressed(&"jump"):
		velocity.y += jump_impulse

	# 每帧应用重力，确保角色始终与地面碰撞。
	velocity.y -= fall_acceleration * delta
	move_and_slide()

	# 检测是否踩到怪物。
	# move_and_slide() 可能多次移动角色以平滑运动，需要遍历所有碰撞。
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group(&"mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				velocity.y = bounce_impulse
				# 防止同一怪物被多次计分。
				break

	# 使角色在跳跃时呈现弧形。
	rotation.x = PI / 6 * velocity.y / jump_impulse


## 玩家死亡。发出信号并销毁。
func die():
	hit.emit()
	queue_free()


## 怪物检测区域碰撞回调。玩家与怪物碰撞时死亡。
func _on_MobDetector_body_entered(_body):
	die()
