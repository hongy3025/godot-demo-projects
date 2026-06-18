## 车辆跟随摄像机 —— 支持外部/内部/俯视三种视角。
##
## 继承自 [Camera3D]，根据车速动态调整 FOV，
## 支持视角切换和物理插值重置。
extends Camera3D

# FOV 速度系数，值越高高速时 FOV 增加越多。
const FOV_SPEED_FACTOR = 60

# FOV 平滑系数，值越高 FOV 适应速度变化越快。
const FOV_SMOOTH_FACTOR = 0.2

# 低于此速度不改变 FOV，防止慢速行驶时阴影闪烁。
const FOV_CHANGE_MIN_SPEED = 0.05

## 与目标的最小距离。
@export var min_distance := 2.0
## 与目标的最大距离。
@export var max_distance := 4.0
## 垂直角度微调（度）。
@export var angle_v_adjust := 0.0
## 摄像机高度。
@export var height := 1.5

## 当前摄像机类型。
var camera_type := CameraType.EXTERIOR

## 初始变换（用于重置外部视角）。
var initial_transform := transform

## 基础 FOV。
var base_fov := fov

## 目标 FOV（用于平滑插值）。
var desired_fov := fov

## 上一物理帧的位置（用于测量速度）。
@onready var previous_position := global_position

## 摄像机类型枚举。
enum CameraType {
	EXTERIOR,  ## 外部视角。
	INTERIOR,  ## 内部视角。
	TOP_DOWN,  ## 俯视视角。
	MAX,       ## 枚举大小。
}

## _ready 入口。初始化摄像机位置。
func _ready() -> void:
	update_camera()


## _input 入口。处理视角切换快捷键。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"cycle_camera"):
		camera_type = wrapi(camera_type + 1, 0, CameraType.MAX) as CameraType
		update_camera()


## _physics_process 入口。每物理帧更新摄像机位置和 FOV。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 外部视角：跟随目标并保持距离/高度
## 2. 俯视视角：跟随目标 XZ 位置
## 3. 根据车速动态调整 FOV
func _physics_process(_delta: float) -> void:
	if camera_type == CameraType.EXTERIOR:
		var target: Vector3 = get_parent().global_transform.origin
		var pos := global_transform.origin

		var from_target := pos - target

		# 限制距离范围。
		if from_target.length() < min_distance:
			from_target = from_target.normalized() * min_distance
		elif from_target.length() > max_distance:
			from_target = from_target.normalized() * max_distance

		from_target.y = height

		pos = target + from_target

		look_at_from_position(pos, target, Vector3.UP)
	elif camera_type == CameraType.TOP_DOWN:
		position.x = get_parent().global_transform.origin.x
		position.z = get_parent().global_transform.origin.z
		# 强制旋转防止在斜坡上切换视角后摄像机倾斜。
		rotation_degrees = Vector3(270, 180, 0)

	# 基于车速的动态 FOV，平滑过渡防止碰撞时突变。
	desired_fov = clamp(base_fov + (abs(global_position.length() - previous_position.length()) - FOV_CHANGE_MIN_SPEED) * FOV_SPEED_FACTOR, base_fov, 100)
	fov = lerpf(fov, desired_fov, FOV_SMOOTH_FACTOR)

	# 微调垂直角度。
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis

	previous_position = global_position


## 更新摄像机视角。切换视角类型并重置物理插值。
func update_camera() -> void:
	match camera_type:
		CameraType.EXTERIOR:
			transform = initial_transform
		CameraType.INTERIOR:
			global_transform = get_node(^"../../InteriorCameraPosition").global_transform
		CameraType.TOP_DOWN:
			global_transform = get_node(^"../../TopDownCameraPosition").global_transform

	# 外部和俯视视角分离变换与父节点。
	set_as_top_level(camera_type != CameraType.INTERIOR)

	# 摄像机切换是即时的，防止物理插值改变外观。
	reset_physics_interpolation()
