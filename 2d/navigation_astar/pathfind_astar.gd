## A* 寻路网格 —— 使用 AStarGrid2D 实现网格寻路。
## 继承自 TileMapLayer，标记障碍物并计算路径。
extends TileMapLayer

# 图块集中起点/终点的图块坐标
const TILE_START_POINT = Vector2i(1, 0)
const TILE_END_POINT = Vector2i(2, 0)

const CELL_SIZE = Vector2i(64, 64)
const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR = Color.WHITE * Color(1, 1, 1, 0.5)

# 2D 网格寻路对象
var _astar := AStarGrid2D.new()

var _start_point := Vector2i()
var _end_point := Vector2i()
var _path := PackedVector2Array()

func _ready() -> void:
	# 区域应匹配可玩区域大小加一（以瓦片为单位）。
	# 本演示中可玩区域为 17×9 瓦片，因此矩形大小为 18×10。
	_astar.region = Rect2i(0, 0, 18, 10)
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	# 遍历所有已使用的瓦片，标记为不可通行
	for pos in get_used_cells():
		_astar.set_point_solid(pos)


## 绘制寻路路径。
func _draw() -> void:
	if _path.is_empty():
		return

	var last_point: Vector2 = _path[0]
	for index in range(1, len(_path)):
		var current_point: Vector2 = _path[index]
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point


## 将本地位置取整到最近的瓦片中心。
func round_local_position(local_position: Vector2i) -> Vector2i:
	return map_to_local(local_to_map(local_position))


## 检查某个位置是否可通行。
func is_point_walkable(local_position: Vector2) -> bool:
	var map_position: Vector2i = local_to_map(local_position)
	if _astar.is_in_boundsv(map_position):
		return not _astar.is_point_solid(map_position)
	return false


## 清除路径和起点/终点标记。
func clear_path() -> void:
	if not _path.is_empty():
		_path.clear()
		erase_cell(_start_point)
		erase_cell(_end_point)
		queue_redraw()


## 计算从起点到终点的路径。
## 参数 local_start_point: 起点本地坐标。
## 参数 local_end_point: 终点本地坐标。
## 返回: 路径点数组。
func find_path(local_start_point: Vector2i, local_end_point: Vector2i) -> PackedVector2Array:
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point)

	if not _path.is_empty():
		set_cell(_start_point, 0, TILE_START_POINT)
		set_cell(_end_point, 0, TILE_END_POINT)

	queue_redraw()

	return _path.duplicate()
