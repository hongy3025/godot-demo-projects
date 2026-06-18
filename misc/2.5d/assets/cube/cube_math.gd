## 3D 立方体旋转演示 —— 生成 27 个点 (3x3x3) 组成立方体并支持旋转。
##
## 继承自 [Node3D]，作为 Cube 场景的子节点存在。
## 在 _ready 中创建 27 个 3D 空间点，每个点对应一个 CubePoint (Node25D)。
## 通过 WASD/QE 旋转立方体，直观展示 2.5D 投影系统如何将 3D 旋转映射到 2D 屏幕。
extends Node3D


## 父节点是否已完成 CubePoint 子节点的添加
var _is_parent_ready: bool = false
## 存储所有 CubePoint 的 3D 子节点引用（用于获取全局变换）
var _cube_points_math: Array[Node3D] = []
## 存储本节点下的 27 个 3D 空间标记点
var _cube_math_spatials: Array[Node3D] = []

@onready var _cube_point_scene: PackedScene = preload("res://assets/cube/cube_point.tscn")
@onready var _parent: Node = get_parent()


## _ready 入口，生成 3x3x3 的立方体点阵。
func _ready() -> void:
	_parent = get_parent()

	# 生成 3x3x3 的立方体点阵，范围 -1 到 1，间距 5 个 3D 单位
	for i in 27:
		@warning_ignore("integer_division")
		var a: int = (i / 9) - 1
		@warning_ignore("integer_division")
		var b: int = (i / 3) % 3 - 1
		var c: int = (i % 3) - 1
		var spatial_position: Vector3 = 5 * (a * Vector3.RIGHT + b * Vector3.UP + c * Vector3.BACK)
		_cube_math_spatials.append(Node3D.new())
		_cube_math_spatials[i].position = spatial_position
		_cube_math_spatials[i].name = "CubeMath #" + str(i) + ", " + str(a) + " " + str(b) + " " + str(c)
		add_child(_cube_math_spatials[i])


## _process 入口，每帧处理立方体旋转并同步 3D 位置到 CubePoint。
func _process(delta: float) -> void:
	if Input.is_action_pressed(&"exit"):
		get_tree().quit()

	if Input.is_action_just_pressed(&"view_cube_demo"):
		get_tree().change_scene_to_file("res://assets/demo_scene.tscn")
		return

	if _is_parent_ready:
		if Input.is_action_just_pressed(&"reset_position"):
			transform = Transform3D.IDENTITY
		else:
			# WASD/QE 旋转: 前/后绕 X 轴，左/右绕 Y 轴，Q/E 绕 Z 轴
			rotate_x(delta * (Input.get_axis(&"move_forward", &"move_back")))
			rotate_y(delta * (Input.get_axis(&"move_left", &"move_right")))
			rotate_z(delta * (Input.get_axis(&"move_clockwise", &"move_counterclockwise")))
		# 将旋转后的 3D 位置同步到每个 CubePoint
		for i in 27:
			_cube_points_math[i].global_transform = _cube_math_spatials[i].global_transform
	else:
		# 首次运行: 实例化 27 个 CubePoint 并添加到父节点
		# 不在 _ready 中执行是因为此时父节点尚未完全就绪
		for i in 27:
			var my_cube_point_scene := _cube_point_scene.duplicate(true)
			var cube_point: Node = my_cube_point_scene.instantiate()
			cube_point.name = "CubePoint #" + str(i)
			_cube_points_math.append(cube_point.get_child(0))
			_parent.add_child(cube_point)
		_is_parent_ready = true
