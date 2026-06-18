## 球体节点 —— 乒乓球，速度逐渐加快，出界时重置。
extends Area2D

## 初始速度。
const DEFAULT_SPEED = 100.0

## 当前速度值。
var _speed := DEFAULT_SPEED
## 移动方向向量。
var direction := Vector2.LEFT

@onready var _initial_pos := position

func _process(delta: float) -> void:
	_speed += delta * 2
	position += _speed * delta * direction


## 重置球体到初始位置和速度。
func reset() -> void:
	direction = Vector2.LEFT
	position = _initial_pos
	_speed = DEFAULT_SPEED
