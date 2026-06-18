## 输入路由 SubViewportContainer —— 根据配置的输入方案，仅将正确的输入事件传递给子视口。
##
## 继承自 [SubViewportContainer]，通过 class_name 注册为可全局使用的类型。
## 支持键盘和手柄输入过滤：键盘按按键码集合过滤，手柄按设备 ID 过滤。
class_name InputRoutingViewportContainer
extends SubViewportContainer

## 当前使用的键盘按键码集合。只有集合中的按键事件才会被传递。
var _current_keyboard_set: Array = []
## 当前使用的手柄设备 ID。为 -1 表示不使用手柄。
var _current_joypad_device: int = -1


## 判断输入事件是否应被传递到子视口。
## 参数:
##   input_event: 输入事件对象
## 返回: [bool] true 表示允许事件通过，false 表示拦截
##
## 键盘事件：检查按键码是否在当前键盘集合中
## 手柄按钮事件：检查设备 ID 是否匹配且已配置手柄
func _propagate_input_event(input_event: InputEvent) -> bool:
	if input_event is InputEventKey:
		if _current_keyboard_set.has(input_event.keycode):
			return true
	elif input_event is InputEventJoypadButton:
		if _current_joypad_device > -1 and input_event.device == _current_joypad_device:
			return true
	return false


## 设置新的输入配置。
## 参数:
##   config_dict: 配置字典，包含 "keyboard"（按键码数组）和 "joypad"（手柄设备 ID）
func set_input_config(config_dict: Dictionary):
	_current_keyboard_set = config_dict["keyboard"]
	_current_joypad_device = config_dict["joypad"]
