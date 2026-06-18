## 2.5D 投影节点 —— 将 3D 空间坐标映射到 2D 平面。
##
## 这是整个 2.5D 系统的核心节点。它继承自 [Node2D]，但要求第一个子节点必须是 [Node3D]。
## 通过三个基向量 (_basisX, _basisY, _basisZ) 将 3D 子节点的位置投影到 2D 画布上。
## 支持 6 种视角模式，每种模式对应不同的投影矩阵。
##
## 投影公式: global_position = spatial_position.x * basisX + spatial_position.y * basisY + spatial_position.z * basisZ
## 缩放因子: 1 个 3D 单位 = 32 像素
@tool
@icon("res://addons/node25d/icons/node_25d_icon.png")
class_name Node25D
extends Node2D


## 2D/3D 单位换算比例。1 个 3D 单位对应 32 个像素。
## 建议使用整数以避免子像素渲染问题。
const SCALE = 32

## 3D 空间位置，暴露给编辑器的导出属性。
## 通过 getter/setter 桥接到 _spatial_node.position。
@export var spatial_position: Vector3:
	get:
		return get_spatial_position()
	set(value):
		set_spatial_position(value)

# 三个基向量，构成 2.5D 投影矩阵的核心。
# 由于 GDScript 不支持自定义结构体（相关 issue 见下方链接），
# 此处用三个独立的 Vector2 变量代替。
# 参考: https://github.com/godotengine/godot/issues/21461
# 参考: https://github.com/godotengine/godot-proposals/issues/279
var _basisX: Vector2
var _basisY: Vector2
var _basisZ: Vector2

# 缓存 3D 空间位置和 3D 子节点引用，避免每帧重复查找。
var _spatial_position: Vector3
var _spatial_node: Node3D


## _ready 入口，委托给 Node25D_ready 以便子类扩展。
func _ready():
	Node25D_ready()


## _process 入口，委托给 Node25D_process 以便子类扩展。
func _process(_delta):
	Node25D_process()


## 初始化 2.5D 系统。应在 _ready 中调用，或在首次调用 Node25D_process 之前调用。
## 获取第一个子节点作为 3D 空间节点，并设置默认的 45 度视角基向量。
func Node25D_ready():
	_spatial_node = get_child(0)
	# 默认视角: 45 度投影
	# X 轴保持水平，Y 轴向上倾斜 -45 度，Z 轴向下倾斜 45 度
	_basisX = SCALE * Vector2(1, 0)
	_basisY = SCALE * Vector2(0, -0.70710678118)
	_basisZ = SCALE * Vector2(0, 0.70710678118)


## 每帧更新 2D 位置。应在 _process 中调用，或在对象位置变化时调用。
## 将 3D 子节点的位置通过基向量投影到 2D 全局坐标。
func Node25D_process():
	_check_view_mode()
	if _spatial_node == null:
		return
	_spatial_position = _spatial_node.position

	# 投影计算: 将 3D 坐标沿三个基向量分解并求和
	var flat_pos = _spatial_position.x * _basisX
	flat_pos += _spatial_position.y * _basisY
	flat_pos += _spatial_position.z * _basisZ

	global_position = flat_pos


## 获取当前投影基向量组。
## 返回: 包含 [_basisX, _basisY, _basisZ] 的数组
func get_basis():
	return [_basisX, _basisY, _basisZ]


## 获取 3D 子节点的空间位置。
## 返回: [Vector3] 3D 坐标
func get_spatial_position():
	if not _spatial_node:
		_spatial_node = get_child(0)
	return _spatial_node.position


## 设置 3D 子节点的空间位置。
## 同时更新内部缓存的 _spatial_position 和 3D 节点的实际位置。
func set_spatial_position(value):
	_spatial_position = value
	if _spatial_node:
		_spatial_node.position = value
	elif get_child_count() > 0:
		_spatial_node = get_child(0)


## 切换视角模式。通过修改三个基向量改变投影方式。
## 实际游戏中如果只需要一种视角，可以移除或替换此方法。
##
## 参数:
##   view_mode_index: 视角模式索引 (0-5)
##     0 - 45 度 (默认)
##     1 - 等距 (Isometric)
##     2 - 俯视 (Top Down)
##     3 - 正面 (Front Side)
##     4 - 斜 Y (Oblique Y)
##     5 - 斜 Z (Oblique Z)
func set_view_mode(view_mode_index):
	match view_mode_index:
		0:  # 45 度投影 —— X 轴水平，Y/Z 轴沿垂直方向对称倾斜
			_basisX = SCALE * Vector2(1, 0)
			_basisY = SCALE * Vector2(0, -0.70710678118)
			_basisZ = SCALE * Vector2(0, 0.70710678118)
		1:  # 等距投影 —— 经典 2:1 像素比例，X/Z 轴对称
			_basisX = SCALE * Vector2(0.86602540378, 0.5)
			_basisY = SCALE * Vector2(0, -1)
			_basisZ = SCALE * Vector2(-0.86602540378, 0.5)
		2:  # 俯视投影 —— 仅保留 X/Z 平面，Y 轴无视觉贡献
			_basisX = SCALE * Vector2(1, 0)
			_basisY = SCALE * Vector2(0, 0)
			_basisZ = SCALE * Vector2(0, 1)
		3:  # 正面投影 —— 仅保留 X/Y 平面，Z 轴无视觉贡献
			_basisX = SCALE * Vector2(1, 0)
			_basisY = SCALE * Vector2(0, -1)
			_basisZ = SCALE * Vector2(0, 0)
		4:  # 斜 Y 投影 —— X 轴水平，Y 轴向左上方倾斜，Z 轴垂直向下
			_basisX = SCALE * Vector2(1, 0)
			_basisY = SCALE * Vector2(-0.70710678118, -0.70710678118)
			_basisZ = SCALE * Vector2(0, 1)
		5:  # 斜 Z 投影 —— X 轴向右上方倾斜，Y 轴垂直向上，Z 轴向右下方倾斜
			_basisX = SCALE * Vector2(1, 0)
			_basisY = SCALE * Vector2(0, -1)
			_basisZ = SCALE * Vector2(-0.70710678118, 0.70710678118)


## 检测视角切换按键输入并更新投影基向量。
## 实际游戏中如果只需要一种视角，可以移除或替换此方法。
func _check_view_mode():
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed(&"forty_five_mode"):
			set_view_mode(0)
		elif Input.is_action_just_pressed(&"isometric_mode"):
			set_view_mode(1)
		elif Input.is_action_just_pressed(&"top_down_mode"):
			set_view_mode(2)
		elif Input.is_action_just_pressed(&"front_side_mode"):
			set_view_mode(3)
		elif Input.is_action_just_pressed(&"oblique_y_mode"):
			set_view_mode(4)
		elif Input.is_action_just_pressed(&"oblique_z_mode"):
			set_view_mode(5)


## 按 Y 轴深度排序的比较函数（供 YSort25D 使用）。
## 仅比较 Y 坐标，不处理同 Y 值的情况。
static func y_sort(a: Node25D, b: Node25D):
	return a._spatial_position.y < b._spatial_position.y


## 带轻微 XZ 修正的 Y 轴排序比较函数（供 YSort25D 使用）。
## 当 Y 坐标相同时，使用 X+Z 做微调（权重 0.001），避免 Z-fighting 式的重叠闪烁。
static func y_sort_slight_xz(a: Node25D, b: Node25D):
	var a_index = a._spatial_position.y + 0.001 * (a._spatial_position.x + a._spatial_position.z)
	var b_index = b._spatial_position.y + 0.001 * (b._spatial_position.x + b._spatial_position.z)
	return a_index < b_index
