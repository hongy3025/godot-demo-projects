## 平台游戏跟随摄像机 —— 自动跟随目标并支持自动转向避障。
##
## 继承自 [Camera3D]，使用三条射线检测障碍物并自动绕开。
## 当主射线被遮挡时拉近摄像机；当侧边射线被遮挡时自动旋转摄像机。
extends Camera3D


## 最大高度差。
const MAX_HEIGHT = 2.0
## 最小高度差。
const MIN_HEIGHT = 0.0

## 碰撞排除列表（RID 数组），防止摄像机与玩家和敌人碰撞。
var collision_exception: Array[RID] = []

## 与目标的最小距离。
@export var min_distance: float = 0.5
## 与目标的最大距离。
@export var max_distance: float = 3.5
## 垂直角度微调（度）。
@export var angle_v_adjust: float = 0.0
## 自动转向射线孔径角度（度）。
@export var autoturn_ray_aperture: float = 25.0
## 自动转向速度。
@export var autoturn_speed: float = 50.0


## _ready 入口。查找碰撞排除对象并设为顶层节点。
func _ready() -> void:
	# 查找碰撞排除对象，防止玩家和敌人与摄像机碰撞。
	var node: Node = self
	while is_instance_valid(node):
		if node is RigidBody3D or node is CharacterBody3D:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()

	# 将摄像机变换与父节点分离。
	set_as_top_level(true)


## _physics_process 入口。每物理帧更新摄像机位置和朝向。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 计算摄像机与目标的偏移向量
## 2. 限制距离和高度范围
## 3. 发射三条射线检测障碍物：
##    - 主射线被遮挡：拉近摄像机（最坏情况）
##    - 仅左侧被遮挡：向右自动旋转
##    - 仅右侧被遮挡：向左自动旋转
##    - 两侧都被遮挡但中间畅通：不自动旋转
## 4. 看向目标并应用垂直角度微调
func _physics_process(delta: float) -> void:
	var target := (get_parent() as Node3D).get_global_transform().origin
	var pos := get_global_transform().origin

	var difference := pos - target

	# 限制距离范围。
	if difference.length() < min_distance:
		difference = difference.normalized() * min_distance
	elif  difference.length() > max_distance:
		difference = difference.normalized() * max_distance

	# 限制高度范围。
	difference.y = clamp(difference.y, MIN_HEIGHT, MAX_HEIGHT)

	# 自动转向检测：发射三条射线。
	var ds := PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())

	var col_left := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(autoturn_ray_aperture)) * (difference),
			0xffffffff,
			collision_exception
		))
	var col := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + difference,
			0xffffffff,
			collision_exception
		))
	var col_right := ds.intersect_ray(PhysicsRayQueryParameters3D.create(
			target,
			target + Basis(Vector3.UP, deg_to_rad(-autoturn_ray_aperture)) * (difference),
			0xffffffff,
			collision_exception
		))

	if not col.is_empty():
		# 主射线被遮挡，拉近摄像机。
		difference = col.position - target
	elif not col_left.is_empty() and col_right.is_empty():
		# 仅左侧被遮挡，向右旋转。
		difference = Basis(Vector3.UP, deg_to_rad(-delta * (autoturn_speed))) * difference
	elif col_left.is_empty() and not col_right.is_empty():
		# 仅右侧被遮挡，向左旋转。
		difference = Basis(Vector3.UP, deg_to_rad(delta * autoturn_speed)) * difference

	# 应用 lookat。
	if difference.is_zero_approx():
		difference = (pos - target).normalized() * 0.0001

	pos = target + difference

	look_at_from_position(pos, target, Vector3.UP)

	# 微调垂直角度。
	transform.basis = Basis(transform.basis[0], deg_to_rad(angle_v_adjust)) * transform.basis
