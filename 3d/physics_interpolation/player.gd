## 物理插值演示玩家控制器 —— 支持固定/FPS/TPS 三种视角。
##
## 继承自 [CharacterBody3D]，演示物理插值（Physics Interpolation）的使用。
## 玩家在 _physics_process 中移动，摄像机在 _process 中更新，
## 展示如何正确使用 get_global_transform_interpolated() 获取插值后的变换。
extends CharacterBody3D

## 鼠标灵敏度。
const MOUSE_SENSITIVITY = 2.5
## 摄像机平滑速度。
const CAMERA_SMOOTH_SPEED = 10.0
## 移动速度。
const MOVE_SPEED = 3.0
## 摩擦力系数。
const FRICTION = 10.0
## 跳跃速度。
const JUMP_VELOCITY = 8.0
## 子弹速度。
const BULLET_SPEED = 9.0

## 子弹场景预加载。
const Bullet = preload("res://bullet.tscn")

# 使用欧拉角定义 FPS 和 TPS 视角。
var _yaw: float = 0.0
var _pitch: float = 0.0

## 玩家在 XZ 平面上的朝向。
var _dir := Vector3(sin(_yaw), 0, cos(_yaw))

## TPS 摄像机距离。
var _tps_camera_proximity: float = 3.0
## TPS 摄像机观察位置。
var _tps_camera_look_from := Vector3()

## 摄像机类型枚举。
enum CameraType {
	CAM_FIXED, ## 固定摄像机视角。
	CAM_FPS,   ## 第一人称视角。
	CAM_TPS,   ## 第三人称视角。
}

## 当前摄像机类型。
var _cam_type := CameraType.CAM_FIXED

## 重力加速度。
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


## _ready 入口。捕获鼠标并初始化 TPS 摄像机。
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# 将 TPS 摄像机设为顶层节点，使其忽略父节点变换。
	$Rig/Camera_TPS.top_level = true

	# 执行逻辑以 FPS 视角开始。
	cycle_camera_type()


## _input 入口。处理鼠标视角控制。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		_yaw -= input_event.screen_relative.x * MOUSE_SENSITIVITY * 0.001
		_pitch += input_event.screen_relative.y * MOUSE_SENSITIVITY * 0.002
		_pitch = clamp(_pitch, -PI, PI)
		$Rig.rotation = Vector3(0, _yaw, 0)


## 更新摄像机位置和朝向。
##
## 参数:
##   delta: 帧时间间隔
##
## TPS 摄像机逻辑：
## 1. 使用 get_global_transform_interpolated() 获取插值后的头部位置
## 2. 根据玩家朝向和俯仰计算摄像机位置
## 3. 限制每帧移动距离实现平滑过渡
func _update_camera(delta: float) -> void:
	_dir.x = sin(_yaw)
	_dir.z = cos(_yaw)

	$Rig/Head.rotation = Vector3(_pitch * -0.5, 0, 0)

	match _cam_type:
		CameraType.CAM_TPS:
			# 将 TPS 摄像机聚焦于玩家头部。
			var target: Vector3 = $Rig/Head.get_global_transform_interpolated().origin

			var pos := target

			# 摄像机应在玩家后方，根据朝向偏移。
			pos.x += _dir.x * _tps_camera_proximity
			pos.z += _dir.z * _tps_camera_proximity

			# 根据俯仰上下移动摄像机。
			pos.y += 2.0 + _pitch * _tps_camera_proximity * 0.2

			# 计算从旧位置到新位置的偏移。
			var offset: Vector3 = pos - _tps_camera_look_from
			var l: float = offset.length()

			# 限制每帧移动距离，实现平滑移动。
			var tps_cam_speed: float = CAMERA_SMOOTH_SPEED * delta

			if l > tps_cam_speed:
				offset *= tps_cam_speed / l

			_tps_camera_look_from += offset

			$Rig/Camera_TPS.look_at_from_position(_tps_camera_look_from, target, Vector3(0, 1, 0))


## 循环切换摄像机类型。
func cycle_camera_type() -> void:
	match _cam_type:
		CameraType.CAM_FIXED:
			_cam_type = CameraType.CAM_FPS
			$Rig/Head/Camera_FPS.make_current()
		CameraType.CAM_FPS:
			_cam_type = CameraType.CAM_TPS
			$Rig/Camera_TPS.make_current()
		CameraType.CAM_TPS:
			_cam_type = CameraType.CAM_FIXED
			get_node(^"../Camera_Fixed").make_current()

	# FPS 视角下隐藏身体（保留阴影投射以提高空间感知）。
	if _cam_type == CameraType.CAM_FPS:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	else:
		$Rig/Mesh_Body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


## _process 入口。处理输入、射击、重置和摄像机更新。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"cycle_camera_type"):
		cycle_camera_type()

	if Input.is_action_just_pressed(&"toggle_physics_interpolation"):
		get_tree().physics_interpolation = not get_tree().physics_interpolation

	if Input.is_action_just_pressed(&"fire"):
		var bullet: RigidBody3D = Bullet.instantiate()

		# 使用 get_global_transform_interpolated() 获取插值后的发射位置。
		var transform_3d: Transform3D = $Rig/Head/Fire_Origin.get_global_transform_interpolated()
		bullet.position = transform_3d.origin

		var bul_dir: Vector3 = transform_3d.basis[2].normalized()

		bullet.linear_velocity = bul_dir * -BULLET_SPEED
		get_parent().add_child(bullet)

		# 为子弹设置移动起点：重置插值后在运动方向偏移位置。
		bullet.reset_physics_interpolation()
		bullet.position -= bul_dir * (1.0 - Engine.get_physics_interpolation_fraction())

	# 重置位置。
	if Input.is_action_just_pressed(&"reset_position") or position.length() > 10.0:
		position = Vector3(0, 1, 0)
		velocity = Vector3()
		reset_physics_interpolation()
		_yaw = 0.0
		_pitch = 0.0
		$Rig.rotation = Vector3(0, _yaw, 0)

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	# 每帧更新摄像机。
	# 摄像机不做物理插值，因为需要快速响应鼠标输入。
	# 但在 FPS/TPS 视角下，位置间接继承自物理插值的玩家，既有平滑运动又有快速响应。
	_update_camera(delta)


## _physics_process 入口。每物理帧处理移动。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 使用物理插值时，应在物理帧（_physics_process）而非渲染帧（_process）中移动节点。
func _physics_process(delta: float) -> void:
	var move := Vector3()

	# 计算相对于玩家坐标系的移动。
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward") * MOVE_SPEED
	move.x = input.x
	move.z = input.y

	# 应用重力。
	move.y -= gravity * delta

	# 应用鼠标旋转到移动方向，转换到世界空间。
	move = move.rotated(Vector3(0, 1, 0), _yaw)

	velocity += move

	move_and_slide()

	# 以帧率无关的方式对水平运动应用摩擦力。
	var friction_delta := exp(-FRICTION * delta)
	velocity = Vector3(velocity.x * friction_delta, velocity.y, velocity.z * friction_delta)
