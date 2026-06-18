## 分屏界面控制器 —— 管理单个分屏的输入配置和玩家设置。
##
## 继承自 [Node]，通过 class_name 注册为可全局使用的类型。
## 每个 SplitScreen 实例对应一个分屏区域，包含 OptionButton 用于选择输入方式（键盘方案或手柄）。
## 通过 InputRoutingViewportContainer 实现输入路由过滤。
class_name SplitScreen
extends Node

## 手柄选项在 OptionButton 中的显示前缀。
const JOYPAD_PREFIX: String = "Joypad"

## 玩家初始位置。
@export var init_position := Vector2.ZERO

## 所有键盘选项的副本字典，键为选项名称，值为包含按键码数组的字典。
var _keyboard_options: Dictionary

## 输入方式选择的下拉菜单。
@onready var opt: OptionButton = $OptionButton
## 渲染玩家画面的子视口。
@onready var viewport: SubViewport = $InputRoutingViewportContainer/SubViewport
## 输入路由容器，负责过滤输入事件。
@onready var input_router: InputRoutingViewportContainer = $InputRoutingViewportContainer
## 分屏中的玩家节点。
@onready var play: Player = $InputRoutingViewportContainer/SubViewport/Player


## 配置此分屏并初始化 OptionButton。
## 参数:
##   config_dict: 配置字典，包含 keyboard（键盘选项）、position（位置）、index（索引）、color（颜色）、joypads（手柄数量）、world（共享的 World2D）
func set_config(config_dict: Dictionary):
	_keyboard_options = config_dict["keyboard"]
	play.position = config_dict["position"]
	var local_index: int = config_dict["index"]
	play.modulate = config_dict["color"]
	opt.clear()
	# 添加所有键盘选项到下拉菜单
	for keyboard_opt in _keyboard_options:
		opt.add_item(keyboard_opt)
	# 添加所有手柄选项到下拉菜单
	for index in config_dict["joypads"]:
		opt.add_item("%s %s" % [JOYPAD_PREFIX, index + 1])
	opt.select(local_index)
	_on_option_button_item_selected(local_index)
	# 将所有分屏连接到同一个 World2D，实现共享物理/绘制空间
	viewport.world_2d = config_dict["world"]


## 响应 OptionButton 选择：更新输入路由配置。
## 参数:
##   index: 选中项的索引
##
## 如果选中手柄选项，配置手柄设备 ID 并清空键盘集合；
## 如果选中键盘选项，配置对应的按键码集合并将手柄设为 -1。
func _on_option_button_item_selected(index: int) -> void:
	var text: String = opt.get_item_text(index)
	if text.begins_with(JOYPAD_PREFIX):
		# 从文本中提取手柄编号（如 "Joypad 1" -> 1）
		input_router.set_input_config({"joypad": text.substr(text.length() - 1, -1).to_int(), "keyboard": []})
	else:
		input_router.set_input_config({"keyboard": _keyboard_options[text]["keys"], "joypad": -1})
