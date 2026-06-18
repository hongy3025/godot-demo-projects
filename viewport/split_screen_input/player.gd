## 分屏输入玩家 —— 接收路由后的输入事件并控制 2D 角色移动。
##
## 继承自 [CharacterBody2D]，通过 class_name 注册为可全局使用的类型。
## 使用 _unhandled_input 接收经过 InputRoutingViewportContainer 过滤后的输入事件，
## 更新移动方向向量，在 _physics_process 中执行实际移动。
class_name Player
extends CharacterBody2D

## 移动速度倍率，用于将方向向量转换为实际像素位移。
const factor: float = 200.0

## 当前移动方向向量，由输入事件更新。
var _movement: Vector2 = Vector2(0, 0)


## 处理到达此子视口的输入事件，更新移动方向。
## 参数:
##   input_event: 输入事件对象
##
## 支持 ux_up/ux_down/ux_left/ux_right 四个动作。
## 按键按下时增加对应方向的值，按键释放时减少对应方向的值。
## 每次处理后调用 set_input_as_handled() 标记事件已处理，防止重复响应。
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ux_up") or input_event.is_action_released(&"ux_down"):
		_movement.y -= 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_down") or input_event.is_action_released(&"ux_up"):
		_movement.y += 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_left") or input_event.is_action_released(&"ux_right"):
		_movement.x -= 1
		get_viewport().set_input_as_handled()
	elif input_event.is_action_pressed(&"ux_right") or input_event.is_action_released(&"ux_left"):
		_movement.x += 1
		get_viewport().set_input_as_handled()


## 物理帧更新：根据移动方向向量移动角色。
## 参数:
##   delta: 帧时间差（秒）
##
## 使用 move_and_collide 进行物理移动，方向向量乘以速度倍率和时间差。
func _physics_process(delta: float) -> void:
	move_and_collide(_movement * factor * delta)
