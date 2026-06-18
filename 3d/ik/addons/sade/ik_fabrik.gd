@tool
## IK FABRIK 节点 —— 使用 FABRIK 算法求解多骨骼 IK 链。
##
## 继承自 [Node3D]，实现 FABRIK（Forward And Backward Reaching Inverse Kinematics）算法。
## 支持多骨骼链、中间关节目标、迭代次数限制、多种更新模式。
##
## FABRIK 算法核心：
## 1. 反向传递（Backward）：从末端执行器向根节点调整位置
## 2. 正向传递（Forward）：从根节点向末端执行器调整位置
## 3. 应用旋转：根据位置调整骨骼旋转
extends Node3D

# FABRIK IK 链的容差（骨骼需要达到的精度）。
const CHAIN_TOLERANCE = 0.01
# 骨骼链的最大迭代次数。
const CHAIN_MAX_ITER = 10

## 目标 Skeleton3D 的节点路径。
@export var skeleton_path: NodePath:
	set(value):
		skeleton_path = value
		if first_call:
			return

		if skeleton_path == null:
			if debug_messages:
				printerr(name, " - IK_FABRIK: 未选择 skeleton_path 的节点路径！")
			return

		var temp = get_node(skeleton_path)
		if temp != null:
			if temp.has_method(&"get_bone_global_pose"):
				skeleton = temp
				bone_IDs = {}

				_make_bone_nodes()

				if debug_messages:
					printerr(name, " - IK_FABRIK: 已连接到新的骨骼")
			else:
				skeleton = null
				if debug_messages:
					printerr(name, " - IK_FABRIK: skeleton_path 未指向骨骼节点！")
		else:
			if debug_messages:
				printerr(name, " - IK_FABRIK: 未选择 skeleton_path 的节点路径！")


## IK 链中的骨骼名称数组。
@export var bones_in_chain: PackedStringArray:
	set(value):
		bones_in_chain = value
		_make_bone_nodes()


## IK 链中每根骨骼的长度数组。
@export var bones_in_chain_lengths: PackedFloat32Array:
	set(value):
		bones_in_chain_lengths = value
		total_length = INF


## 更新模式：0=_process, 1=_physics_process, 2=_notification, 3=none。
@export_enum("_process", "_physics_process", "_notification", "none") var update_mode: int = 0:
	set(value):
		update_mode = value

		set_process(false)
		set_physics_process(false)
		set_notify_transform(false)

		if update_mode == 0:
			set_process(true)
		elif update_mode == 1:
			set_process(true)
		elif update_mode == 2:
			set_notify_transform(true)
		else:
			if debug_messages:
				printerr(name, " - IK_FABRIK: 未知更新模式。不更新骨骼")
			return

## IK 目标节点。
var target: Node3D = null

## 目标 Skeleton3D 节点引用。
var skeleton: Skeleton3D

## 骨骼 ID 字典（骨骼名称 -> 骨骼索引）。
var bone_IDs = {}
## 骨骼辅助节点字典。
var bone_nodes = {}

## IK 链原点位置。
var chain_origin = Vector3()
## IK 链所有骨骼的总长度。
var total_length = INF
## 当前迭代次数。
@export var chain_iterations: int = 0
## 是否限制迭代次数。
@export var limit_chain_iterations: bool = true
## 是否在每次更新时重置迭代计数。
@export var reset_iterations_on_update: bool = false

## 是否使用中间关节目标。
@export var use_middle_joint_target: bool = false
## 中间关节目标节点。
var middle_joint_target: Node3D = null

## 首次调用标记。
var first_call = true

## 是否输出调试信息。
var debug_messages = false


## _ready 入口。初始化目标节点、中间关节目标和骨骼节点。
func _ready():
	if target == null:
		# 注意：此节点下必须有一个名为 Target 的子节点！
		if not has_node(^"Target"):
			target = Node3D.new()
			add_child(target)

			if Engine.is_editor_hint():
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						target.set_owner(get_tree().edited_scene_root)

			target.name = &"Target"
		else:
			target = $Target

		if Engine.is_editor_hint():
			_make_editor_sphere_at_node(target, Color.MAGENTA)

	if middle_joint_target == null:
		if not has_node(^"MiddleJoint"):
			middle_joint_target = Node3D.new()
			add_child(middle_joint_target)

			if Engine.is_editor_hint():
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						middle_joint_target.set_owner(get_tree().edited_scene_root)

			middle_joint_target.name = &"MiddleJoint"
		else:
			middle_joint_target = get_node(^"MiddleJoint")

		if Engine.is_editor_hint():
			_make_editor_sphere_at_node(middle_joint_target, Color(1, 0.24, 1, 1))

	_make_bone_nodes()

	update_mode = update_mode


func _process(_delta):
	if reset_iterations_on_update:
		chain_iterations = 0
	update_skeleton()


func _physics_process(_delta):
	if reset_iterations_on_update:
		chain_iterations = 0
	update_skeleton()


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if reset_iterations_on_update:
			chain_iterations = 0
		update_skeleton()


############# IK 求解器相关函数 #############

## 更新骨骼。初始化骨骼 ID 和总长度，然后求解 IK 链。
func update_skeleton():
	# 错误检查。
	if first_call:
		skeleton_path = skeleton_path
		first_call = false

		if skeleton == null:
			skeleton_path = skeleton_path

		return

	if bones_in_chain == null:
		if debug_messages:
			printerr(name, " - IK_FABRIK: IK 链中未定义骨骼！")
		return
	if bones_in_chain_lengths == null:
		if debug_messages:
			printerr(name, " - IK_FABRIK: IK 链中未定义骨骼长度！")
		return

	if bones_in_chain.size() != bones_in_chain_lengths.size():
		if debug_messages:
			printerr(name, " - IK_FABRIK: bones_in_chain 和 bones_in_chain_lengths 大小不匹配！")
		return

	# 如果尚未设置，初始化所有骨骼 ID。
	var i = 0
	if bone_IDs.size() <= 0:
		for bone_name in bones_in_chain:
			bone_IDs[bone_name] = skeleton.find_bone(bone_name)

			bone_nodes[i].global_transform = get_bone_transform(i)
			if i < bone_IDs.size()-1:
				bone_nodes[i].look_at(get_bone_transform(i+1).origin + skeleton.global_transform.origin, Vector3.UP)

			i += 1

	# 如果尚未设置，计算总长度。
	if total_length == INF:
		total_length = 0
		for bone_length in bones_in_chain_lengths:
			total_length += bone_length

	# 求解 IK 链。
	solve_chain()


## FABRIK 求解器主循环。
##
## 核心算法：
## 1. 检查是否达到最大迭代次数
## 2. 更新原点位置
## 3. 计算末端执行器方向
## 4. 计算目标位置（考虑末端骨骼长度）
## 5. 可选：将中间关节拉向中间目标
## 6. 循环执行反向传递 -> 正向传递 -> 应用旋转，直到误差在容差范围内
func solve_chain():
	if chain_iterations >= CHAIN_MAX_ITER and limit_chain_iterations:
		return
	else:
		chain_iterations = 0

	chain_origin = get_bone_transform(0).origin

	# 获取末端骨骼的方向。
	var dir
	if bone_nodes.size() > 2:
		dir = bone_nodes[bone_nodes.size()-2].global_transform.basis.z.normalized()
	else:
		dir = -target.global_transform.basis.z.normalized()

	# 计算目标位置（考虑末端骨骼长度）。
	var target_pos = target.global_transform.origin + (dir * bones_in_chain_lengths[bone_nodes.size()-1])

	# 如果使用中间关节目标，将中间关节拉向目标。
	if use_middle_joint_target:
		if bone_nodes.size() > 2:
			var middle_point_pos = middle_joint_target.global_transform.origin
			var middle_point_pos_diff = (middle_point_pos - bone_nodes[bone_nodes.size()/2].global_transform.origin)
			bone_nodes[bone_nodes.size()/2].global_transform.origin += middle_point_pos_diff.normalized()

	# 计算末端执行器与目标的距离差。
	var dif = (bone_nodes[bone_nodes.size()-1].global_transform.origin - target_pos).length()

	# 迭代求解直到误差在容差范围内。
	while dif > CHAIN_TOLERANCE:
		chain_backward()
		chain_forward()
		chain_apply_rotation()

		dif = (bone_nodes[bone_nodes.size()-1].global_transform.origin - target_pos).length()

		chain_iterations = chain_iterations + 1
		if chain_iterations >= CHAIN_MAX_ITER:
			break

	# 重置骨骼节点变换为骨骼变换。
	for i in range(0, bone_nodes.size()):
		var reset_bone_trans = get_bone_transform(i)
		bone_nodes[i].global_transform = reset_bone_trans


## FABRIK 反向传递：从末端执行器向根节点调整位置。
func chain_backward():
	var dir
	if bone_nodes.size() > 2:
		dir = bone_nodes[bone_nodes.size() - 2].global_transform.basis.z.normalized()
	else:
		dir = -target.global_transform.basis.z.normalized()

	# 将末端执行器设置到目标位置。
	bone_nodes[bone_nodes.size()-1].global_transform.origin = target.global_transform.origin + (dir * bones_in_chain_lengths[bone_nodes.size()-1])

	# 反向遍历所有骨骼，向目标方向移动。
	var i = bones_in_chain.size() - 1
	while i >= 1:
		var prev_origin = bone_nodes[i].global_transform.origin
		i -= 1
		var curr_origin = bone_nodes[i].global_transform.origin

		var r = prev_origin - curr_origin
		var l = bones_in_chain_lengths[i] / r.length()
		bone_nodes[i].global_transform.origin = prev_origin.lerp(curr_origin, l)


## FABRIK 正向传递：从根节点向末端执行器调整位置。
func chain_forward():
	# 将根节点设回原点。
	bone_nodes[0].global_transform.origin = chain_origin

	# 正向遍历所有骨骼。
	for i in range(bones_in_chain.size() - 1):
		var curr_origin = bone_nodes[i].global_transform.origin
		var next_origin = bone_nodes[i + 1].global_transform.origin

		var r = next_origin - curr_origin
		var l = bones_in_chain_lengths[i] / r.length()
		bone_nodes[i + 1].global_transform.origin = curr_origin.lerp(next_origin, l)


## 应用骨骼旋转：根据位置调整所有骨骼的旋转。
func chain_apply_rotation():
	for i in range(0, bones_in_chain.size()):
		var bone_trans = get_bone_transform(i, false)
		# 如果是最后一根骨骼。
		if i == bones_in_chain.size() - 1:
			if bones_in_chain.size() > 2:
				var b_target = bone_nodes[i].global_transform
				var b_target_two = bone_nodes[i-1].global_transform

				b_target.origin = b_target.origin * skeleton.global_transform
				b_target_two.origin = b_target_two.origin * skeleton.global_transform

				var dir = (target.global_transform.origin - b_target_two.origin).normalized()

				bone_trans = bone_trans.looking_at(b_target.origin + dir, Vector3.UP)
				bone_trans.origin = b_target.origin

			else:
				var b_target = target.global_transform
				b_target.origin = b_target.origin * skeleton.global_transform
				bone_trans = bone_trans.looking_at(b_target.origin, Vector3.UP)

				var last_bone = bone_nodes[i-1].global_transform
				bone_trans.origin = last_bone.origin - last_bone.basis.z.normalized() * bones_in_chain_lengths[i-1]

		# 如果不是最后一根骨骼，使其朝向下一个骨骼。
		else:
			var b_target = bone_nodes[i].global_transform
			var b_target_two = bone_nodes[i+1].global_transform

			b_target.origin = b_target.origin * skeleton.global_transform
			b_target_two.origin = b_target_two.origin * skeleton.global_transform

			var dir = (b_target_two.origin - b_target.origin).normalized()

			bone_trans = bone_trans.looking_at(b_target.origin + dir, Vector3.UP)
			bone_trans.origin = b_target.origin

		set_bone_transform(i, bone_trans)


## 获取骨骼变换。
##
## 参数:
##   bone: 骨骼索引
##   convert_to_world_space: 是否转换为世界空间
##
## 返回: [Transform3D] 骨骼变换
func get_bone_transform(bone, convert_to_world_space = true):
	var ret: Transform3D = skeleton.get_bone_global_pose(bone_IDs[bones_in_chain[bone]])

	if convert_to_world_space:
		ret.origin = skeleton.global_transform * (ret.origin)

	return ret


## 设置骨骼变换。
##
## 参数:
##   bone: 骨骼索引
##   trans: 要设置的变换
func set_bone_transform(bone, trans):
	skeleton.set_bone_global_pose_override(bone_IDs[bones_in_chain[bone]], trans, 1.0, true)

############# IK 求解器相关函数结束 #############


## 在编辑器中为目标节点创建可视化球体。
##
## 参数:
##   node: 目标节点
##   color: 球体颜色
func _make_editor_sphere_at_node(node, color):
	var indicator = MeshInstance3D.new()
	node.add_child(indicator)
	indicator.name = &"(EditorOnly) 可视化指示器"

	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = 0.1
	indicator_mesh.height = 0.2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4

	var indicator_material = StandardMaterial3D.new()
	indicator_material.flags_unshaded = true
	indicator_material.albedo_texture = preload("editor_gizmo_texture.png")
	indicator_material.albedo_color = color
	indicator_mesh.material = indicator_material
	indicator.mesh = indicator_mesh

############# 其他（非 IK 求解器相关）函数 #############

## 创建骨骼辅助节点。
func _make_bone_nodes():
	for bone in range(0, bones_in_chain.size()):
		var bone_name = bones_in_chain[bone]
		if not has_node(bone_name):
			var new_node = Node3D.new()
			bone_nodes[bone] = new_node
			add_child(bone_nodes[bone])

			if Engine.is_editor_hint():
				if get_tree() != null:
					if get_tree().edited_scene_root != null:
						bone_nodes[bone].set_owner(get_tree().edited_scene_root)

			bone_nodes[bone].name = bone_name

		else:
			bone_nodes[bone] = get_node(bone_name)

		if Engine.is_editor_hint():
			_make_editor_sphere_at_node(bone_nodes[bone], Color(0.65, 0, 1, 1))
