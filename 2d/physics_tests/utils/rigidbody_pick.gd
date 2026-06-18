## 刚体拾取脚本 —— 使 RigidBody2D 可被鼠标拖拽。
extends RigidBody2D

## 是否正在被拖拽。
var _picked: bool = false
## 上一帧的鼠标位置，用于计算速度。
var _last_mouse_pos := Vector2.ZERO


func _ready() -> void:
	input_pickable = true


## 松开鼠标按钮时取消拾取。
func _input(any_input_event: InputEvent) -> void:
	var mouse_event := any_input_event as InputEventMouseButton
	if mouse_event and not mouse_event.pressed:
		_picked = false


## 鼠标点击刚体时开始拾取。
func _input_event(_viewport: Node, any_input_event: InputEvent, _shape_idx: int) -> void:
	var mouse_event := any_input_event as InputEventMouseButton
	if mouse_event and mouse_event.pressed:
		_picked = true
		_last_mouse_pos = get_global_mouse_position()


## 物理帧更新：被拾取时跟随鼠标。
func _physics_process(delta: float) -> void:
	if _picked:
		var mouse_pos := get_global_mouse_position()
		if freeze:
			# 冻结时直接设置位置
			global_position = mouse_pos
		else:
			# 非冻结时通过速度驱动
			linear_velocity = (mouse_pos - _last_mouse_pos) / delta
			_last_mouse_pos = mouse_pos
