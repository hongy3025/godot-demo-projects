## 运动学角色控制器 —— Cubio 角色。
##
## 继承自 [CharacterBody3D]，实现第三人称视角下的移动、跳跃和重力。
## 移动方向基于摄像机朝向，支持加速/减速和物理插值重置。
extends CharacterBody3D

## 最大移动速度。
const MAX_SPEED = 3.5
## 跳跃速度。
const JUMP_SPEED = 6.5
## 加速度（朝移动方向）。
const ACCELERATION = 4
## 减速度（朝相反方向）。
const DECELERATION = 4

## 摄像机节点引用（作为子节点）。
@onready var camera: Camera3D = $Target/Camera3D
## 重力加速度（从项目设置读取）。
@onready var gravity := float(-ProjectSettings.get_setting("physics/3d/default_gravity"))
## 起始位置，用于重置。
@onready var start_position := position


## _physics_process 入口。每物理帧处理输入、移动和跳跃。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 处理退出和位置重置
## 2. 读取 WASD 输入并转换为摄像机相对方向
## 3. 应用重力
## 4. 根据移动方向与当前速度的点积选择加速或减速
## 5. 调用 move_and_slide() 移动
## 6. 处理跳跃
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()
	if Input.is_action_just_pressed(&"reset_position") or global_position.y < -6.0:
		# 按下重置键或掉落出地面。
		position = start_position
		velocity = Vector3.ZERO
		# 传送玩家后重置物理插值，防止从旧位置插值到新位置。
		reset_physics_interpolation()

	var dir := Vector3()
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.z = Input.get_axis(&"move_forward", &"move_back")

	# 获取摄像机的变换基，但移除 X 轴旋转使 Y 轴朝上、Z 轴水平。
	var cam_basis := camera.global_transform.basis
	cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = cam_basis * dir

	# 限制输入向量长度不超过 1。`length_squared()` 比 `length()` 更快。
	if dir.length_squared() > 1:
		dir /= dir.length()

	# 应用重力。
	velocity.y += delta * gravity

	# 仅使用水平速度进行插值。
	var hvel := velocity
	hvel.y = 0

	var target := dir * MAX_SPEED
	var acceleration := 0.0
	if dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.lerp(target, acceleration * delta)

	# 将水平速度赋值回 velocity。
	velocity.x = hvel.x
	velocity.z = hvel.z
	move_and_slide()

	# 跳跃。is_on_floor() 必须在 move_and_slide() 之后调用。
	if is_on_floor() and Input.is_action_pressed(&"jump"):
		velocity.y = JUMP_SPEED


## 目标立方体碰撞回调。玩家到达目标时显示胜利文本。
##
## 参数:
##   body: 进入区域的 PhysicsBody3D
func _on_tcube_body_entered(body: PhysicsBody3D) -> void:
	if body == self:
		$WinText.show()
