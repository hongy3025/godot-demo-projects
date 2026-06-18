## 编辑器 2.5D Gizmo —— 在 2.5D 视口中提供三轴拖拽操作手柄。
##
## 显示 X（红）、Y（绿）、Z（蓝）三个轴向的拖拽线，
## 鼠标靠近某条轴线时高亮显示，点击拖拽可沿该轴移动选中的 Node25D 对象。
## 使用投影基向量将 2D 鼠标移动映射回 3D 空间位移。
@tool
extends Node2D


## 鼠标捕捉死区半径（像素）。鼠标距离轴线超过此值则不响应。
const DEADZONE_RADIUS = 20.0
const DEADZONE_RADIUS_SQ = DEADZONE_RADIUS * DEADZONE_RADIUS
## 是否在拖拽过程中进行粗略的像素对齐。
## 并非所有视角模式的所有轴向都能完美对齐，但效果足够好。
## 精确对齐在拖拽结束后才执行。
const ROUGHLY_ROUND_TO_PIXELS = true

## 关联的 Node25D 节点（在创建时设置）
var node_25d: Node25D
## 关联的 3D 空间节点（Node25D 的第一个子节点）
var _spatial_node: Node3D

## 来自 Viewport25D 的输入信号，表示鼠标是否按下。
var wants_to_move: bool = false

## 是否正在拖拽中
var _moving: bool = false
## 拖拽起始时的鼠标位置
var _start_mouse_position := Vector2.ZERO

## 当前主导轴索引（0=X, 1=Y, 2=Z），-1 表示未选中任何轴
var _dominant_axis: int = -1

@onready var _lines = [$X, $Y, $Z]
@onready var _viewport_overlay: SubViewport = get_parent()
@onready var _viewport_25d_bg: ColorRect = _viewport_overlay.get_parent()


## _process 入口，每帧更新 Gizmo 位置、检测鼠标交互并处理拖拽。
func _process(_delta: float) -> void:
	if not _lines:
		return  # 节点尚未初始化
	if not node_25d or not _viewport_25d_bg:
		return  # 正在查看 Gizmo25D 场景本身
	# 将 Gizmo 定位到 Node25D 的 2D 位置
	global_position = node_25d.global_position
	# 获取鼠标在 2.5D 视口中的本地坐标
	var mouse_position: Vector2 = _viewport_25d_bg.get_local_mouse_position()
	# 将鼠标坐标从屏幕空间转换到 Gizmo 的本地空间
	var full_transform: Transform2D = _viewport_overlay.canvas_transform * global_transform
	mouse_position = full_transform.affine_inverse() * mouse_position
	if not _moving:
		determine_dominant_axis(mouse_position)
		if _dominant_axis == -1:
			return  # 鼠标不在任何轴线上
	# 高亮当前选中的轴线
	_lines[_dominant_axis].modulate.a = 1
	if not wants_to_move:
		if _moving:
			# 拖拽结束，通知 Node25D 更新属性面板
			node_25d.notify_property_list_changed()
			_moving = false
		return
	# 开始/继续拖拽
	if not _moving:
		_moving = true
		_start_mouse_position = mouse_position
	move_using_mouse(mouse_position)


## 检测鼠标最靠近哪条轴线，设置 _dominant_axis。
## 如果鼠标距离所有轴线都超过 DEADZONE_RADIUS，则设为 -1。
func determine_dominant_axis(mouse_position: Vector2) -> void:
	var closest_distance = DEADZONE_RADIUS
	_dominant_axis = -1
	for i in range(3):
		_lines[i].modulate.a = 0.8  # 同时恢复所有轴线透明度
		var distance = _distance_to_segment_at_index(i, mouse_position)
		if distance < closest_distance:
			closest_distance = distance
			_dominant_axis = i


## 根据鼠标拖拽位移计算并应用 3D 空间移动。
##
## 将 2D 鼠标位移投影到选中轴线的 2D 方向上，
## 再通过 Node25D.SCALE 换算回 3D 单位，沿对应 3D 轴向移动。
func move_using_mouse(mouse_position: Vector2) -> void:
	# 降低非选中轴线的透明度
	_lines[(_dominant_axis + 1) % 3].modulate.a = 0.5
	_lines[(_dominant_axis + 2) % 3].modulate.a = 0.5
	# 计算鼠标位移在选中轴线方向上的投影长度
	var mouse_diff: Vector2 = mouse_position - _start_mouse_position
	var line_end_point: Vector2 = _lines[_dominant_axis].points[1]
	var projected_diff: Vector2 = mouse_diff.project(line_end_point)
	var movement: float = projected_diff.length() * global_scale.x / Node25D.SCALE
	# 如果投影方向与轴线方向相反，取负值
	if is_equal_approx(PI, projected_diff.angle_to(line_end_point)):
		movement *= -1
	# 沿 3D 轴向移动
	var move_dir_3d: Vector3 = _spatial_node.transform.basis[_dominant_axis]
	_spatial_node.transform.origin += move_dir_3d * movement
	_snap_spatial_position()
	# 更新 Gizmo 位置
	global_position = node_25d.global_position


## 初始化 Gizmo。在 Viewport25D.gd 中手动调用。
## 根据 Node25D 的基向量设置三条轴线的方向和长度。
func setup(in_node_25d: Node25D):
	node_25d = in_node_25d
	var basis = node_25d.get_basis()
	for i in range(3):
		_lines[i].points[1] = basis[i] * 3
	global_position = node_25d.global_position
	_spatial_node = node_25d.get_child(0)


## 设置 Gizmo 的缩放比例，以匹配视口缩放。
func set_zoom(zoom: float) -> void:
	var new_scale: float = EditorInterface.get_editor_scale() / zoom
	global_scale = Vector2(new_scale, new_scale)


## 将 3D 空间位置对齐到最近的像素网格。
## 步长默认为 1/SCALE 个 3D 单位（即 1 像素）。
func _snap_spatial_position(step_meters: float = 1.0 / Node25D.SCALE) -> void:
	var scaled_px: Vector3 = _spatial_node.transform.origin / step_meters
	_spatial_node.transform.origin = scaled_px.round() * step_meters


## 计算鼠标点到指定轴线线段的距离。
## 假设线段起点为 (0, 0)，并提供原点附近的死区保护。
func _distance_to_segment_at_index(index, point):
	if not _lines:
		return INF
	# 原点附近不响应，避免三轴交叉区域误触
	if point.length_squared() < DEADZONE_RADIUS_SQ:
		return INF

	var segment_end: Vector2 = _lines[index].points[1]
	var length_squared = segment_end.length_squared()
	if length_squared < DEADZONE_RADIUS_SQ:
		return INF

	# 计算点到线段的最短距离
	var t = clamp(point.dot(segment_end) / length_squared, 0, 1)
	var projection = t * segment_end
	return point.distance_to(projection)
