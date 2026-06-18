## 虚拟摇杆 —— 为触屏设备提供简单的虚拟摇杆控件。
##
## 继承自 [Control]，支持固定/动态/跟随三种模式，
## 可选的可见性控制和输入动作绑定。
## Github: https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot
class_name VirtualJoystick
extends Control

# 导出变量

## 摇杆按下时按钮的颜色。
@export var pressed_color := Color.GRAY

## 输入在此范围内时输出为零。
@export_range(0, 200, 1) var deadzone_size: float = 10.0

## 摇杆尖端可达到的最大距离。
@export_range(0, 500, 1) var clampzone_size: float = 75.0

## 摇杆模式枚举。
enum Joystick_mode {
	FIXED,     ## 摇杆不移动。
	DYNAMIC,   ## 每次按下摇杆区域时，摇杆位置设置在触摸位置。
	FOLLOWING, ## 手指移出摇杆区域时，摇杆跟随移动。
}

## 摇杆是否固定在原位或在触摸时出现在触摸位置。
@export var joystick_mode := Joystick_mode.FIXED

## 可见性模式枚举。
enum Visibility_mode {
	ALWAYS,            ## 始终可见。
	TOUCHSCREEN_ONLY,  ## 仅在触屏设备上可见。
	WHEN_TOUCHED,      ## 仅在触摸时可见。
}

## 摇杆是否始终可见，或仅在触屏设备上显示。
@export var visibility_mode := Visibility_mode.ALWAYS

## 如果为 true，摇杆使用输入动作（项目 -> 项目设置 -> 输入映射）。
@export var use_input_actions: bool = true

## 左移输入动作名称。
@export var action_left: String = "move_left"
## 右移输入动作名称。
@export var action_right: String = "move_right"
## 前移输入动作名称。
@export var action_up: String = "move_forward"
## 后移输入动作名称。
@export var action_down: String = "move_back"

# 公开变量

## 摇杆是否正在接收输入。
var is_pressed: bool = false

## 摇杆输出向量。
var output := Vector2.ZERO

# 私有变量

## 当前触摸索引。
var _touch_index: int = -1

## 摇杆底座 TextureRect。
@onready var _base: TextureRect = $Base
## 摇杆尖端 TextureRect。
@onready var _tip: TextureRect = $Base/Tip

## 底座默认位置。
@onready var _base_default_position: Vector2 = _base.position
## 尖端默认位置。
@onready var _tip_default_position: Vector2 = _tip.position

## 默认颜色。
@onready var _default_color : Color = _tip.modulate


## _ready 入口。根据设备和可见性模式控制摇杆显示。
func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		hide()

	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		hide()


## _input 入口。处理触屏触摸和拖拽事件。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventScreenTouch:
		if input_event.pressed:
			if _is_point_inside_joystick_area(input_event.position) and _touch_index == -1:
				if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING or (
						joystick_mode == Joystick_mode.FIXED and _is_point_inside_base(input_event.position)):
					if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING:
						_move_base(input_event.position)
					if visibility_mode == Visibility_mode.WHEN_TOUCHED:
						show()
					_touch_index = input_event.index
					_tip.modulate = pressed_color
					_update_joystick(input_event.position)
					get_viewport().set_input_as_handled()
		elif input_event.index == _touch_index:
			_reset()
			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()
			get_viewport().set_input_as_handled()
	elif input_event is InputEventScreenDrag:
		if input_event.index == _touch_index:
			_update_joystick(input_event.position)
			get_viewport().set_input_as_handled()


## 移动底座到新位置。
##
## 参数:
##   new_position: 新位置（屏幕坐标）
func _move_base(new_position: Vector2) -> void:
	_base.global_position = new_position - _base.pivot_offset * get_global_transform_with_canvas().get_scale()


## 移动尖端到新位置。
##
## 参数:
##   new_position: 新位置（屏幕坐标）
func _move_tip(new_position: Vector2) -> void:
	_tip.global_position = new_position - _tip.pivot_offset * _base.get_global_transform_with_canvas().get_scale()


## 检测点是否在摇杆区域内。
##
## 参数:
##   point: 检测点
##
## 返回: [bool] 是否在区域内
func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y


## 获取底座半径。
##
## 返回: [Vector2] 底座半径
func _get_base_radius() -> Vector2:
	return _base.size * _base.get_global_transform_with_canvas().get_scale() / 2.0


## 检测点是否在底座范围内。
##
## 参数:
##   point: 检测点
##
## 返回: [bool] 是否在底座内
func _is_point_inside_base(point: Vector2) -> bool:
	var base_radius: Vector2 = _get_base_radius()
	var center: Vector2 = _base.global_position + base_radius
	var vector: Vector2 = point - center
	return vector.length_squared() <= base_radius.x * base_radius.x


## 更新摇杆状态。计算输出向量并触发输入动作。
##
## 参数:
##   touch_position: 触摸位置
##
## 核心逻辑：
## 1. 计算触摸位置相对于底座中心的向量
## 2. 限制向量长度不超过 clampzone_size
## 3. 跟随模式下超出范围时移动底座
## 4. 应用死区计算输出值
## 5. 如果启用输入动作，触发对应的 action_press/action_release
func _update_joystick(touch_position: Vector2) -> void:
	var base_radius: Vector2 = _get_base_radius()
	var center: Vector2 = _base.global_position + base_radius
	var vector: Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)

	if joystick_mode == Joystick_mode.FOLLOWING and touch_position.distance_to(center) > clampzone_size:
		_move_base(touch_position - vector)

	_move_tip(center + vector)

	if vector.length_squared() > deadzone_size * deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		is_pressed = false
		output = Vector2.ZERO

	if use_input_actions:
		# 释放动作。
		if output.x >= 0.0 and Input.is_action_pressed(action_left):
			Input.action_release(action_left)
		if output.x <= 0.0 and Input.is_action_pressed(action_right):
			Input.action_release(action_right)
		if output.y >= 0.0 and Input.is_action_pressed(action_up):
			Input.action_release(action_up)
		if output.y <= 0.0 and Input.is_action_pressed(action_down):
			Input.action_release(action_down)

		# 按下动作。
		if output.x < 0.0:
			Input.action_press(action_left, -output.x)
		if output.x > 0.0:
			Input.action_press(action_right, output.x)
		if output.y < 0.0:
			Input.action_press(action_up, -output.y)
		if output.y > 0.0:
			Input.action_press(action_down, output.y)


## 重置摇杆到默认状态。
func _reset() -> void:
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	# 释放所有输入动作。
	if use_input_actions:
		for action:String in [action_left, action_right, action_down, action_up]:
			if Input.is_action_pressed(action):
				Input.action_release(action)
