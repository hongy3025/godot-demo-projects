## 输入路由 SubViewportContainer —— 根据配置的输入方案，仅将正确的输入事件传递给子视口。
##
## 继承自 [SubViewportContainer]，通过 class_name 注册为可全局使用的类型。
## 支持键盘和手柄输入过滤：键盘按按键码集合过滤，手柄按设备 ID 过滤。
class_name InputRoutingViewportContainer
## 继承自 SubViewportContainer，该节点用于容纳 SubViewport 并负责将其内容渲染到屏幕上，
## 同时可以拦截或转发输入事件。
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

## 当前允许的键盘按键集合，类型为 Array，初始为空数组。
## 只有该数组中包含的按键码对应的键盘事件，才会被转发到子视口。
var _current_keyboard_set: Array = []
## 当前允许的手柄设备 ID，类型为 int，初始值为 -1。
## -1 表示当前没有允许任何手柄设备；若设为具体编号，则只转发该手柄的事件。
var _current_joypad_device: int = -1


## _propagate_input_event 是 SubViewportContainer 的虚函数，用于在将输入事件传播给子视口之前进行过滤。
## 返回 true 表示允许该事件继续传播到 SubViewport；返回 false 则阻止传播。
func _propagate_input_event(input_event: InputEvent) -> bool:
	# 判断输入事件是否为键盘按键事件（InputEventKey）。
	if input_event is InputEventKey:
		# 检查该按键的 keycode 是否存在于当前允许的键盘集合中。
		if _current_keyboard_set.has(input_event.keycode):
			# 如果存在，返回 true，允许该键盘事件传播到 SubViewport。
			return true
	# 否则，判断输入事件是否为手柄按键事件（InputEventJoypadButton）。
	elif input_event is InputEventJoypadButton:
		# 判断条件：当前已启用手柄（_current_joypad_device > -1），
		# 并且事件来源的设备 ID 与当前允许的设备 ID 完全一致。
		if _current_joypad_device > -1 and input_event.device == _current_joypad_device:
			# 条件满足，返回 true，允许该手柄事件传播到 SubViewport。
			return true
	# 对于所有不符合上述条件的事件，返回 false，阻止其传播到 SubViewport。
	# 这样就实现了输入隔离，避免多个分屏的玩家互相干扰对方的输入。
	return false


## 设置新的输入配置。
## 参数:
##   config_dict: 配置字典，包含 "keyboard"（按键码数组）和 "joypad"（手柄设备 ID）
## 为输入处理设置新的配置。
## 接收一个字典参数 config_dict，该字典通常由 SplitScreen 在切换 OptionButton 选项时生成并传入。
func set_input_config(config_dict: Dictionary):
	# 从配置字典中取出 "keyboard" 键对应的值（按键码数组），赋值给 _current_keyboard_set。
	# 后续键盘事件将依据此集合进行过滤。
	_current_keyboard_set = config_dict["keyboard"]
	# 从配置字典中取出 "joypad" 键对应的值（手柄设备 ID，整数），赋值给 _current_joypad_device。
	# 若为 -1，则表示禁止所有手柄事件；若为 0/1/2/3 等，则只接受对应手柄的事件。
	_current_joypad_device = config_dict["joypad"]
