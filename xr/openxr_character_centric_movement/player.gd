## 以角色为中心的 XR 玩家控制器 —— 管理 VR 中基于 CharacterBody3D 的移动。
## 继承自 [CharacterBody3D]，处理玩家物理移动（房间尺度）和控制器输入移动，
## 并处理碰撞遮挡时的屏幕变黑效果。
extends CharacterBody3D

## 旋转速度，控制控制器输入旋转的灵敏度。
@export var rotation_speed := 1.0
## 移动速度，控制控制器输入移动的最大速度。
@export var movement_speed := 5.0
## 移动加速度，控制速度变化的平滑程度。
@export var movement_acceleration := 5.0

## 重力值，从项目设置中获取，与 [RigidBody3D] 保持一致。
var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

## XROrigin3D 节点引用。
@onready var origin_node: XROrigin3D = $XROrigin3D
## XR 相机节点引用。
@onready var camera_node: XRCamera3D = $XROrigin3D/XRCamera3D
## 颈部位置节点引用，用于计算相机高度偏移。
@onready var neck_position_node: Node3D = $XROrigin3D/XRCamera3D/Neck
## 黑屏节点引用，当玩家碰撞到障碍物时变暗屏幕。
@onready var black_out: Node3D = $XROrigin3D/XRCamera3D/BlackOut


## 重定中心视图 —— 根据 OpenXR 的游玩区域模式重置玩家位置。
## 支持坐姿、房间尺度和 Godot 默认三种模式。
func recenter() -> void:
	var xr_interface: OpenXRInterface = XRServer.find_interface("OpenXR")
	if not xr_interface:
		push_error("Couldn't access OpenXR interface!")
		return

	var play_area_mode: XRInterface.PlayAreaMode = xr_interface.get_play_area_mode()
	if play_area_mode == XRInterface.XR_PLAY_AREA_SITTING:
		push_warning("Sitting play space is not suitable for this setup.")
	elif play_area_mode == XRInterface.XR_PLAY_AREA_ROOMSCALE:
		# 房间尺度由头显自行处理
		pass
	else:
		# 使用 Godot 自身的重定中心逻辑
		XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

	# XRCamera3D 节点尚未更新，直接从追踪器获取数据
	var head_tracker: XRPositionalTracker = XRServer.get_tracker(&"head")
	if not head_tracker:
		push_error("Couldn't locate head tracker!")
		return

	var pose: XRPose = head_tracker.get_pose(&"default")
	var head_transform: Transform3D = pose.get_adjusted_transform()

	# 获取颈部在 XROrigin3D 空间中的变换
	var neck_transform: Transform3D = neck_position_node.transform * head_transform

	# 重置 XROrigin 变换并应用颈部位置的反向偏移
	var new_origin_transform: Transform3D = Transform3D()
	new_origin_transform.origin.x = -neck_transform.origin.x
	new_origin_transform.origin.y = 0.0
	new_origin_transform.origin.z = -neck_transform.origin.z
	origin_node.transform = new_origin_transform

	# 重置角色朝向
	transform.basis = Basis()


## 获取移动输入 —— 查询左右手柄的移动操作值。
## 返回: [Vector2] 合并后的移动输入向量
func _get_movement_input() -> Vector2:
	var movement := Vector2()

	# 累加左右手柄的移动输入
	movement += $XROrigin3D/LeftHand.get_vector2(&"move")
	movement += $XROrigin3D/RightHand.get_vector2(&"move")

	return movement


## 处理物理移动 —— 根据玩家的实际物理移动调整角色身体位置。
## 参数:
##   delta: 物理帧时间间隔
## 返回: [bool] 是否发生碰撞（需要黑屏）
##
## 逻辑:
##   1. 将角色身体旋转到与玩家实际朝向一致
##   2. 根据相机位置计算角色身体应处位置
##   3. 使用 move_and_slide 移动角色身体
##   4. 同步 XROrigin 位置并处理高度变化
##   5. 如果移动受阻（偏移 > 0.1），设置黑屏透明度
func _process_on_physical_movement(delta: float) -> bool:
	var current_velocity := velocity

	# 将角色身体旋转到与玩家实际朝向一致
	var camera_basis: Basis = origin_node.transform.basis * camera_node.transform.basis
	var forward: Vector2 = Vector2(camera_basis.z.x, camera_basis.z.z)
	var angle: float = forward.angle_to(Vector2(0.0, 1.0))

	# 旋转角色身体
	transform.basis = transform.basis.rotated(Vector3.UP, angle)

	# 反向旋转 XROrigin 节点
	origin_node.transform = Transform3D().rotated(Vector3.UP, -angle) * origin_node.transform

	# 移动角色身体到正确位置
	var org_player_body: Vector3 = global_transform.origin
	var player_body_location: Vector3 = origin_node.transform * camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	velocity = (player_body_location - org_player_body) / delta
	move_and_slide()

	# 将 XROrigin 移回
	var delta_movement := global_transform.origin - org_player_body
	origin_node.global_transform.origin -= delta_movement

	# 抵消局部空间中的高度变化（如斜坡）
	origin_node.transform.origin.y = 0.0

	# 恢复速度
	velocity = current_velocity

	# 检查位置偏移量
	var location_offset := (player_body_location - global_transform.origin).length()
	if location_offset > 0.1:
		# 无法移动到目标位置，黑屏
		black_out.fade = clampf((location_offset - 0.1) / 0.1, 0.0, 1.0)
		return true
	else:
		black_out.fade = 0.0
		return false


## 处理控制器输入移动 —— 旋转和移动玩家。
## 参数:
##   is_colliding: 是否发生物理碰撞
##   delta: 物理帧时间间隔
##
## 逻辑:
##   1. 如果未碰撞，读取控制器输入
##   2. 先处理旋转（绕 Y 轴平滑旋转）
##   3. 再处理前后移动（带加速度平滑）
##   4. 始终应用重力
##   5. 移动角色身体
func _process_movement_on_input(is_colliding: bool, delta: float) -> void:
	if not is_colliding:
		var movement_input := _get_movement_input()

		# 处理旋转（平滑旋转，可能导致晕动症）
		rotation.y += -movement_input.x * delta * rotation_speed

		# 处理前后移动
		var direction := global_transform.basis * Vector3(0.0, 0.0, -movement_input.y) * movement_speed
		if direction:
			velocity.x = move_toward(velocity.x, direction.x, delta * movement_acceleration)
			velocity.z = move_toward(velocity.z, direction.z, delta * movement_acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, delta * movement_acceleration)
			velocity.z = move_toward(velocity.z, 0, delta * movement_acceleration)

	# 始终应用重力
	velocity.y -= gravity * delta

	move_and_slide()


## _physics_process 物理帧更新 —— 处理玩家移动。
## 参数:
##   delta: 物理帧时间间隔
##
## 先处理物理移动（房间尺度），再处理控制器输入移动。
func _physics_process(delta: float) -> void:
	var is_colliding := _process_on_physical_movement(delta)
	_process_movement_on_input(is_colliding, delta)
