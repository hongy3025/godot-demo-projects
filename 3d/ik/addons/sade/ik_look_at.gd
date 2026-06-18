@tool
## IK LookAt 节点 —— 使骨骼的指定骨头始终朝向目标位置。
##
## 继承自 [Node3D]，通过设置骨骼全局姿态覆盖实现单骨头的 IK LookAt 效果。
## 支持多种更新模式（_process/_physics_process/_notification）、
## 自定义朝向轴、插值平滑、附加旋转和附加骨骼定位。
extends Node3D

## 目标 Skeleton3D 的节点路径。
@export var skeleton_path: NodePath:
	set(value):
		skeleton_path = value
		# 首次调用时 get_node 不可用，仅赋值。
		if first_call:
			return
		_setup_skeleton_path()
## 要控制的骨骼名称。
@export var bone_name: String = ""
## 更新模式：0=_process, 1=_physics_process, 2=_notification, 3=none。
@export_enum("_process", "_physics_process", "_notification", "none") var update_mode: int = 0:
	set(value):
		update_mode = value

		# 禁用所有处理模式。
		set_process(false)
		set_physics_process(false)
		set_notify_transform(false)

		# 根据传入值启用对应的处理模式。
		if update_mode == 0:
			set_process(true)
			if debug_messages:
				print(name, " - IK_LookAt: 使用 _process 更新骨骼...")
		elif update_mode == 1:
			set_physics_process(true)
			if debug_messages:
				print(name, " - IK_LookAt: 使用 _physics_process 更新骨骼...")
		elif update_mode == 2:
			set_notify_transform(true)
			if debug_messages:
				print(name, " - IK_LookAt: 使用 _notification 更新骨骼...")
		else:
			if debug_messages:
				print(name, " - IK_LookAt: 未知更新方法，不更新骨骼...")

## 朝向轴：0=X-up, 1=Y-up, 2=Z-up。
@export_enum("X-up", "Y-up", "Z-up") var look_at_axis: int = 1
## 插值系数（0.0~1.0），1.0 为直接设置。
@export_range(0.0, 1.0, 0.001) var interpolation: float = 1.0
## 是否使用本节点的 X 轴旋转。
@export var use_our_rotation_x: bool = false
## 是否使用本节点的 Y 轴旋转。
@export var use_our_rotation_y: bool = false
## 是否使用本节点的 Z 轴旋转。
@export var use_our_rotation_z: bool = false
## 是否使用负的本节点旋转。
@export var use_negative_our_rot: bool = false
## 附加旋转（欧拉角，度）。
@export var additional_rotation: Vector3 = Vector3()
## 是否使用附加骨骼定位位置。
@export var position_using_additional_bone: bool = false
## 附加骨骼名称。
@export var additional_bone_name: String = ""
## 附加骨骼长度。
@export var additional_bone_length: float = 1
## 是否输出调试信息。
@export var debug_messages: bool = false

## 目标 Skeleton3D 节点引用。
var skeleton_to_use: Skeleton3D = null
## 首次调用标记，用于绕过 NodePath 在 _ready 中不可用的问题。
var first_call: bool = true
## 编辑器中的可视化指示器。
var _editor_indicator: Node3D = null


## _ready 入口。根据 update_mode 启用对应的处理模式。
func _ready():
	set_process(false)
	set_physics_process(false)
	set_notify_transform(false)

	if update_mode == 0:
		set_process(true)
	elif update_mode == 1:
		set_physics_process(true)
	elif update_mode == 2:
		set_notify_transform(true)
	else:
		if debug_messages:
			print(name, " - IK_LookAt: 未知更新模式。不更新骨骼")

	if Engine.is_editor_hint():
		_setup_for_editor()


func _process(_delta):
	update_skeleton()


func _physics_process(_delta):
	update_skeleton()


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_skeleton()


## 更新骨骼姿态。核心 IK LookAt 逻辑。
##
## 核心算法：
## 1. 获取骨骼的全局姿态
## 2. 将目标位置转换到骨骼空间
## 3. 使用 looking_at 使骨骼朝向目标
## 4. 应用本节点旋转、附加旋转
## 5. 如果启用，使用附加骨骼定位位置
## 6. 通过 set_bone_global_pose_override 应用
func update_skeleton():
	# 首次调用时跳过，因为 get_node 在 _ready 中不可用。
	if first_call:
		first_call = false
		if skeleton_to_use == null:
			_setup_skeleton_path()

	# 如果没有骨骼或不更新，则返回。
	if skeleton_to_use == null:
		return
	if update_mode >= 3:
		return

	# 获取骨骼索引。
	var bone: int = skeleton_to_use.find_bone(bone_name)

	# 如果未找到骨骼，返回并可选打印错误。
	if bone == -1:
		if debug_messages:
			print(name, " - IK_LookAt: 在骨骼中未找到名为 [", bone_name, "] 的骨骼！")
		return

	# 获取骨骼的全局姿态。
	var rest = skeleton_to_use.get_bone_global_pose(bone)

	# 将本节点位置转换到骨骼空间。
	var target_pos = global_transform.origin * skeleton_to_use.global_transform

	# 使用选择的朝上轴调用 looking_at。
	if look_at_axis == 0:
		rest = rest.looking_at(target_pos, Vector3.RIGHT)
	elif look_at_axis == 1:
		rest = rest.looking_at(target_pos, Vector3.UP)
	elif look_at_axis == 2:
		rest = rest.looking_at(target_pos, Vector3.FORWARD)
	else:
		rest = rest.looking_at(target_pos, Vector3.UP)
		if debug_messages:
			print(name, " - IK_LookAt: 未知的 look_at_axis 值！")

	# 获取骨骼和本节点的旋转欧拉角。
	var rest_euler = rest.basis.get_euler()
	var self_euler = global_transform.basis.orthonormalized().get_euler()

	# 如果使用负旋转，翻转欧拉角。
	if use_negative_our_rot:
		self_euler = -self_euler

	# 按需应用本节点的旋转。
	if use_our_rotation_x:
		rest_euler.x = self_euler.x
	if use_our_rotation_y:
		rest_euler.y = self_euler.y
	if use_our_rotation_z:
		rest_euler.z = self_euler.z

	# 用修改后的欧拉角创建新基。
	rest.basis = Basis.from_euler(rest_euler)

	# 应用附加旋转。
	if additional_rotation != Vector3.ZERO:
		rest.basis = rest.basis.rotated(rest.basis.x, deg_to_rad(additional_rotation.x))
		rest.basis = rest.basis.rotated(rest.basis.y, deg_to_rad(additional_rotation.y))
		rest.basis = rest.basis.rotated(rest.basis.z, deg_to_rad(additional_rotation.z))

	# 如果使用附加骨骼定位，基于该骨骼及其长度设置位置。
	if position_using_additional_bone:
		var additional_bone_id = skeleton_to_use.find_bone(additional_bone_name)
		var additional_bone_pos = skeleton_to_use.get_bone_global_pose(additional_bone_id)
		rest.origin = (
				additional_bone_pos.origin
				- additional_bone_pos.basis.z.normalized() * additional_bone_length
			)

	# 应用新的旋转到骨骼。
	skeleton_to_use.set_bone_global_pose_override(bone, rest, interpolation, true)


## 在编辑器中创建可视化指示器。
func _setup_for_editor():
	_editor_indicator = MeshInstance3D.new()
	add_child(_editor_indicator)
	_editor_indicator.name = &"(EditorOnly) 可视化指示器"

	var indicator_mesh = SphereMesh.new()
	indicator_mesh.radius = 0.1
	indicator_mesh.height = 0.2
	indicator_mesh.radial_segments = 8
	indicator_mesh.rings = 4

	var indicator_material = StandardMaterial3D.new()
	indicator_material.flags_unshaded = true
	indicator_material.albedo_texture = preload("editor_gizmo_texture.png")
	indicator_material.albedo_color = Color(1, 0.5, 0, 1)

	indicator_mesh.material = indicator_material
	_editor_indicator.mesh = indicator_mesh


## 设置骨骼路径并获取 Skeleton3D 引用。
func _setup_skeleton_path():
	if skeleton_path == null:
		if debug_messages:
			print(name, " - IK_LookAt: 未选择 skeleton_path 的节点路径！")
		return

	var temp = get_node(skeleton_path)
	if temp != null:
		if temp is Skeleton3D:
			skeleton_to_use = temp
			if debug_messages:
				print(name, " - IK_LookAt: 已连接到（新）骨骼")
		else:
			skeleton_to_use = null
			if debug_messages:
				print(name, " - IK_LookAt: skeleton_path 未指向骨骼节点！")
	else:
		if debug_messages:
			print(name, " - IK_LookAt: 未选择 skeleton_path 的节点路径！")
