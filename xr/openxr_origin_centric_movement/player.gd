## 以原点为中心的 XR 玩家控制器 —— 管理 VR 中的移动、旋转和物理碰撞。
## 继承自 [XROrigin3D]，处理玩家物理移动（房间尺度）和控制器输入移动，
## 并处理碰撞遮挡时的屏幕变黑效果。
extends XROrigin3D

## 旋转速度，控制控制器输入旋转的灵敏度。
@export var rotation_speed := 1.0
## 移动速度，控制控制器输入移动的最大速度。
@export var movement_speed := 5.0
## 移动加速度，控制速度变化的平滑程度。
@export var movement_acceleration := 5.0

## 重力值，从项目设置中获取，与 [RigidBody3D] 保持一致。
var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

## 角色物理体节点引用，用于处理碰撞和移动。
@onready var character_body : CharacterBody3D = $CharacterBody3D
## XR 相机节点引用。
@onready var camera_node : XRCamera3D = $XRCamera3D
## 颈部位置节点引用，用于计算相机高度偏移。
@onready var neck_position_node : Node3D = $XRCamera3D/Neck
## 黑屏节点引用，当玩家碰撞到障碍物时变暗屏幕。
@onready var black_out : Node3D = $XRCamera3D/BlackOut


## 重定中心视图 —— 将玩家位置重置到角色身体位置。
## 当玩家走到不应进入的区域时调用，将玩家送回角色身体位置。
## 计算相机应处的位置，去除倾斜，更新 XROrigin 和角色身体变换。
func recenter() -> void:
	# 从角色身体的全局变换开始计算相机新位置
	var new_camera_transform: Transform3D = character_body.global_transform

	# 设置到颈部关节的高度
	new_camera_transform.origin.y = neck_position_node.global_position.y

	# 应用颈部位置的反向变换得到期望的相机变换
	new_camera_transform = new_camera_transform * neck_position_node.transform.inverse()

	# 去除相机变换中的倾斜，保持水平
	var camera_transform: Transform3D = camera_node.transform
	var forward_dir: Vector3 = camera_transform.basis.z
	forward_dir.y = 0.0
	camera_transform = camera_transform.looking_at(camera_transform.origin + forward_dir.normalized(), Vector3.UP, true)

	# 更新 XROrigin 位置
	global_transform = new_camera_transform * camera_transform.inverse()

	# 重置角色身体变换
	character_body.transform = Transform3D()


## 获取移动输入 —— 查询左右手柄的移动操作值。
## 返回: [Vector2] 合并后的移动输入向量
## 如果移动操作未绑定到某手柄，该手柄返回 [Vector2.ZERO]。
func _get_movement_input() -> Vector2:
	var movement : Vector2 = Vector2()

	# 累加左右手柄的移动输入
	movement += $LeftHand.get_vector2(&"move")
	movement += $RightHand.get_vector2(&"move")

	return movement


## 处理物理移动 —— 根据玩家的实际物理移动调整角色身体位置。
## 参数:
##   delta: 物理帧时间间隔
## 返回: [bool] 是否发生碰撞（需要黑屏）
##
## 逻辑:
##   1. 根据相机位置计算角色身体应处位置
##   2. 使用 move_and_slide 移动角色身体
##   3. 如果移动受阻（偏移 > 0.1），设置黑屏透明度
func _process_on_physical_movement(delta: float) -> bool:
	# 保存当前速度，后续恢复
	var current_velocity := character_body.velocity

	# 记录角色身体的原始位置
	var org_player_body: Vector3 = character_body.global_transform.origin

	# 计算角色身体应处的位置
	var player_body_location: Vector3 = camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	# 尝试移动角色身体
	character_body.velocity = (player_body_location - org_player_body) / delta
	character_body.move_and_slide()

	# 恢复原始速度
	character_body.velocity = current_velocity

	# 检查是否完全移动到位（忽略高度变化）
	var movement_left := player_body_location - character_body.global_transform.origin
	movement_left.y = 0.0

	# 检查位置偏移量
	var location_offset := movement_left.length()
	if location_offset > 0.1:
		# 无法移动到目标位置，黑屏
		black_out.fade = clamp((location_offset - 0.1) / 0.1, 0.0, 1.0)

		return true
	else:
		black_out.fade = 0.0
		return false


## 将玩家相机的朝向复制到角色身体 —— 仅复制水平方向，忽略倾斜。
func _copy_player_rotation_to_character_body() -> void:
	var camera_forward := -camera_node.global_transform.basis.z
	var body_forward := Vector3(camera_forward.x, 0.0, camera_forward.z)

	character_body.global_transform.basis = Basis.looking_at(body_forward, Vector3.UP)


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
##   5. 移动角色身体并同步 XROrigin 位置
func _process_movement_on_input(is_colliding: bool, delta: float) -> void:
	# 记录角色身体的原始位置
	var org_player_body: Vector3 = character_body.global_transform.origin

	if not is_colliding:
		# 仅在未物理移动到不应去的位置时处理输入
		var movement_input := _get_movement_input()

		# 处理旋转（平滑旋转，可能导致晕动症）
		var t1 := Transform3D()
		var t2 := Transform3D()
		var rot := Transform3D()

		# 围绕玩家旋转 XROrigin
		var player_position := character_body.global_transform.origin - global_transform.origin

		t1.origin = -player_position
		t2.origin = player_position
		rot = rot.rotated(Vector3(0.0, 1.0, 0.0), -movement_input.x * delta * rotation_speed)
		global_transform = (global_transform * t2 * rot * t1).orthonormalized()

		# 确保角色身体朝向正确
		_copy_player_rotation_to_character_body()

		# 处理前后移动
		var direction: Vector3 = (character_body.global_transform.basis * Vector3(0.0, 0.0, -movement_input.y)) * movement_speed
		if direction:
			character_body.velocity.x = move_toward(character_body.velocity.x, direction.x, delta * movement_acceleration)
			character_body.velocity.z = move_toward(character_body.velocity.z, direction.z, delta * movement_acceleration)
		else:
			character_body.velocity.x = move_toward(character_body.velocity.x, 0, delta * movement_acceleration)
			character_body.velocity.z = move_toward(character_body.velocity.z, 0, delta * movement_acceleration)

	# 始终应用重力
	character_body.velocity.y -= gravity * delta

	# 移动角色身体
	character_body.move_and_slide()

	# 将实际移动应用到 XROrigin
	global_transform.origin += character_body.global_transform.origin - org_player_body


## _physics_process 物理帧更新 —— 处理玩家移动。
## 参数:
##   delta: 物理帧时间间隔
##
## 先处理物理移动（房间尺度），再处理控制器输入移动。
func _physics_process(delta: float) -> void:
	var is_colliding := _process_on_physical_movement(delta)
	_process_movement_on_input(is_colliding, delta)
