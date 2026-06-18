## 刚体角色控制器 —— Cubio 角色（RigidBody3D 版）。
##
## 继承自 [RigidBody3D]，使用物理冲量实现移动和跳跃。
## 使用 ShapeCast3D 检测地面接触，支持空中和地面不同加速度。
extends RigidBody3D

## ShapeCast3D 节点，用于检测地面接触。
@onready var shape_cast: ShapeCast3D = $ShapeCast3D
## 摄像机节点引用。
@onready var camera: Camera3D = $Target/Camera3D
## 起始位置，用于重置。
@onready var start_position := position

## _physics_process 入口。每物理帧处理输入和物理冲量。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 处理退出和位置重置
## 2. 读取 WASD 输入并转换为摄像机相对方向
## 3. 空中移动使用较低加速度（5.0）
## 4. 地面移动使用较高加速度（10.0）
## 5. 地面时检测跳跃输入
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()
	if Input.is_action_just_pressed(&"reset_position") or global_position.y < -6.0:
		# 按下重置键或掉落出地面。
		position = start_position
		linear_velocity = Vector3.ZERO
		# 传送玩家后重置物理插值，防止从旧位置插值到新位置。
		reset_physics_interpolation()

	var dir := Vector3()
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.z = Input.get_axis(&"move_forward", &"move_back")

	# 获取摄像机的变换基，但移除 X 轴旋转使 Y 轴朝上、Z 轴水平。
	var cam_basis := camera.global_transform.basis
	cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = cam_basis * dir

	# 空中移动。
	apply_central_impulse(dir.normalized() * 5.0 * delta)

	if on_ground():
		# 地面移动（更高加速度）。
		apply_central_impulse(dir.normalized() * 10.0 * delta)

		# 跳跃。
		# 此处直接设置 linear_velocity.y 而非累加，防止 ShapeCast3D 连续多帧碰撞时跳跃过高。
		if Input.is_action_pressed(&"jump"):
			linear_velocity.y = 7


## 检测玩家是否在地面上。
##
## 返回: [bool] 如果 ShapeCast3D 检测到碰撞则返回 true
func on_ground() -> bool:
	return shape_cast.is_colliding()


## 目标立方体碰撞回调。玩家到达目标时显示胜利文本。
##
## 参数:
##   body: 进入区域的节点
func _on_tcube_body_entered(body: Node) -> void:
	if body == self:
		$WinText.visible = true
