## 跟随摄像机（刚体角色版）—— 始终跟随目标节点并保持一定距离。
##
## 继承自 [Camera3D]，作为目标节点的子节点使用。
## 自动跟随父节点的位置，保持最小/最大距离和高度范围，支持垂直角度微调。
extends Camera3D

## 碰撞排除列表，防止摄像机与自身角色碰撞。
var collision_exception := []
## 最大高度差。
var max_height := 2.0
## 最小高度差。
var min_height := 0

## 与目标的最小距离。
@export var min_distance := 0.5
## 与目标的最大距离。
@export var max_distance := 3.0
## 垂直角度微调（度），用于略微俯视或仰视。
@export var angle_v_adjust := 0.0
## 跟随的目标节点（父节点）。
@onready var target_node: Node3D = get_parent()

## _ready 入口。设置碰撞排除并将摄像机设为顶层节点。
func _ready() -> void:
	collision_exception.append(target_node.get_parent().get_rid())
	# 将摄像机变换与父节点分离，实现独立位置控制。
	top_level = true


## _physics_process 入口。每物理帧更新摄像机位置和朝向。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 计算摄像机与目标的偏移向量
## 2. 将偏移距离限制在最小/最大范围内
## 3. 将高度限制在最小/最大范围内
## 4. 从目标位置+偏移计算摄像机位置
## 5. 看向目标并应用垂直角度微调
func _physics_process(_delta: float) -> void:
	var target_pos := target_node.global_transform.origin
	var camera_pos := global_transform.origin

	var delta_pos := camera_pos - target_pos

	# 限制距离范围。
	if delta_pos.length() < min_distance:
		delta_pos = delta_pos.normalized() * min_distance
	elif delta_pos.length() > max_distance:
		delta_pos = delta_pos.normalized() * max_distance

	# 限制高度范围。
	delta_pos.y = clamp(delta_pos.y, min_height, max_height)
	camera_pos = target_pos + delta_pos

	look_at_from_position(camera_pos, target_pos, Vector3.UP)

	# 微调垂直角度。
	var t := transform
	t.basis = Basis(t.basis[0], deg_to_rad(angle_v_adjust)) * t.basis
	transform = t
