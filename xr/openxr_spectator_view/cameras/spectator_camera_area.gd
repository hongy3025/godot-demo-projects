## 旁观者相机交互区域 —— 允许用户通过 XR 指针拖拽移动旁观者相机。
## 继承自 [Area3D]，检测 XR 指针的进入/离开，并在用户按住交互按钮时
## 将控制器的移动转换为相机的平移。
extends Area3D

## 交互操作名称，对应 OpenXR 操作映射中的操作。
@export var interaction_action: String = "interact"

## 父相机节点引用。
var _parent_camera: Camera3D
## 当前指向此区域的 XR 指针。
var _current_pointer: XRPointer
## 当前捕获的 XR 控制器（按住按钮时持续跟踪）。
var _controller: XRController3D
## 上一帧的控制器位置（用于计算移动增量）。
var _was_pos: Vector3


## 查找给定节点的 XRController3D 祖先节点。
## 参数:
##   node: 起始节点
## 返回: [XRController3D] 或 null
func _get_controller(node: Node3D) -> XRController3D:
	var parent = node.get_parent()
	while parent:
		if parent is XRController3D:
			return parent
		parent = parent.get_parent()
	return null


## _ready 初始化 —— 获取父相机引用。
func _ready():
	_parent_camera = get_parent()


## _process 每帧更新 —— 处理控制器拖拽移动相机。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 如果没有控制器，尝试从指针获取
##   2. 捕获控制器后，计算控制器移动增量
##   3. 将增量转换到相机的局部平面空间并移动相机
func _process(_delta):
	if not _parent_camera:
		return

	# 如果没有控制器，尝试从指针查找
	if not _controller:
		if not _current_pointer:
			return

		# 查找指针相关的控制器
		var controller = _get_controller(_current_pointer)
		if controller:
			if not controller.is_button_pressed(interaction_action):
				return

			# 捕获此控制器，即使指针离开也继续跟踪直到按钮释放
			_controller = controller

			# 计算控制器在相机平面上的初始位置
			var plane: Plane = Plane(global_basis.z, global_position)
			_was_pos = plane.intersects_ray(_controller.global_position, -_controller.global_basis.z)
	else:
		if not _controller.is_button_pressed(interaction_action):
			_controller = null
			return

		# 计算控制器移动增量
		var plane: Plane = Plane(global_basis.z, global_position)
		var new_pos = plane.intersects_ray(_controller.global_position, -_controller.global_basis.z)

		var movement = new_pos - _was_pos
		_was_pos = new_pos

		# 将移动转换到局部空间并仅保留水平分量
		movement = global_basis.inverse() * movement
		movement *= Vector3(1.0, 1.0, 0.0)
		_parent_camera.global_position += global_basis * movement


## 指针进入区域回调。
## 参数:
##   pointer: 进入的 XR 指针
##   _at: 碰撞点位置
func _enter_pointer(pointer: XRPointer, _at: Vector3) -> void:
	_current_pointer = pointer


## 指针离开区域回调。
## 参数:
##   pointer: 离开的 XR 指针
##   _at: 碰撞点位置
func _exit_pointer(pointer: XRPointer, _at: Vector3) -> void:
	if _current_pointer == pointer:
		_current_pointer = null
