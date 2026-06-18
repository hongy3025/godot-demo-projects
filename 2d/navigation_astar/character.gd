## A* 寻路角色 —— 沿 AStarGrid2D 计算出的路径移动。
extends Node2D


const PathFindAStar = preload("./pathfind_astar.gd")

## 角色状态枚举。
enum State {
	IDLE,    # 待机
	FOLLOW,  # 跟随路径
}

## 质量参数，影响转向灵敏度。
const MASS: float = 10.0
## 到达路径点的距离容差。
const ARRIVE_DISTANCE: float = 10.0

## 移动速度。
@export_range(10, 500, 0.1, "or_greater") var speed: float = 200.0

## 当前状态。
var _state := State.IDLE
## 当前速度向量。
var _velocity := Vector2()

## 鼠标点击位置。
var _click_position := Vector2()
## 路径点数组。
var _path := PackedVector2Array()
## 下一个目标路径点。
var _next_point := Vector2()

## 瓦片地图引用。
@onready var _tile_map: PathFindAStar = $"../TileMapLayer"


func _ready() -> void:
	_change_state(State.IDLE)


## 物理帧更新：沿路径移动到下一个点。
func _physics_process(_delta: float) -> void:
	if _state != State.FOLLOW:
		return

	var arrived_to_next_point: bool = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(State.IDLE)
			return
		_next_point = _path[0]


## 处理鼠标点击：点击可通行位置时移动或传送。
func _unhandled_input(input_event: InputEvent) -> void:
	_click_position = get_global_mouse_position()
	if _tile_map.is_point_walkable(_click_position):
		if input_event.is_action_pressed(&"teleport_to", false, true):
			_change_state(State.IDLE)
			global_position = _tile_map.round_local_position(_click_position)
			reset_physics_interpolation()
		elif input_event.is_action_pressed(&"move_to"):
			_change_state(State.FOLLOW)


## 向目标位置移动（使用转向力）。
## 参数 local_position: 目标位置。
## 返回: 是否到达目标。
func _move_to(local_position: Vector2) -> bool:
	var desired_velocity: Vector2 = (local_position - position).normalized() * speed
	var steering: Vector2 = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_physics_process_delta_time()
	rotation = _velocity.angle()
	return position.distance_to(local_position) < ARRIVE_DISTANCE


## 切换状态。
func _change_state(new_state: State) -> void:
	if new_state == State.IDLE:
		_tile_map.clear_path()
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, _click_position)
		if _path.size() < 2:
			_change_state(State.IDLE)
			return
		# 索引 0 是起始格，此处不希望角色移回起点
		_next_point = _path[1]
	_state = new_state
