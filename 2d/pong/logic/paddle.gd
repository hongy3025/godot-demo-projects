## 球拍节点 —— 玩家控制的乒乓球拍。
## 根据名称自动绑定上下移动按键，碰撞球体时改变其方向。
extends Area2D

## 移动速度。
const MOVE_SPEED = 100.0

## 球的方向（左拍为 1，右拍为 -1）。
var _ball_dir: int
## 上移动作名称。
var _up: String
## 下移动作名称。
var _down: String

@onready var _screen_size_y := get_viewport_rect().size.y

func _ready() -> void:
	var n := String(name).to_lower()
	_up = n + "_move_up"
	_down = n + "_move_down"
	if n == "left":
		_ball_dir = 1
	else:
		_ball_dir = -1


## 每帧根据输入上下移动。
func _process(delta: float) -> void:
	var input := Input.get_action_strength(_down) - Input.get_action_strength(_up)
	position.y = clamp(position.y + input * MOVE_SPEED * delta, 16, _screen_size_y - 16)


## 碰撞球体时赋予新的方向。
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Ball":
		area.direction = Vector2(_ball_dir, randf() * 2 - 1).normalized()
