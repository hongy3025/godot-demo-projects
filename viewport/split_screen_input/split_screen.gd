## Interface for a SplitScreen
## SplitScreen（分屏）的接口与逻辑控制脚本。
## 定义类名 SplitScreen，方便在 root.gd 等脚本中通过类型判断识别分屏节点。
class_name SplitScreen
## 继承自 Node，作为该分屏子树的根节点，负责统筹子节点的配置与交互。
extends Node


## 手柄前缀字符串，值为 "Joypad"。
## 用于在 OptionButton 的文本中标识手柄选项，例如 "Joypad 1"、"Joypad 2" 等。
const JOYPAD_PREFIX: String = "Joypad"

## 初始位置，类型推断为 Vector2，默认值为 Vector2.ZERO。
## 该属性会暴露在编辑器检查器中，允许在场景内直接设置，但代码中实际使用的是 root.gd 传入的配置位置。
@export var init_position := Vector2.ZERO

## 键盘选项字典，用于保存当前可用的所有键盘按键配置副本。
## 在 set_config 中从外部传入，供后续 OptionButton 填充下拉菜单使用。
var _keyboard_options: Dictionary

## 获取名为 "OptionButton" 的子节点（选项按钮），用于让玩家选择使用哪套键盘或哪个手柄。
## @onready 表示在节点进入场景树并完成初始化后执行此赋值。
@onready var opt: OptionButton = $OptionButton
## 获取 InputRoutingViewportContainer 下的 SubViewport 子节点。
## 该视口负责渲染实际的游戏画面，并且所有分屏会共享同一个 World2D。
@onready var viewport: SubViewport = $InputRoutingViewportContainer/SubViewport
## 获取 InputRoutingViewportContainer 子节点实例。
## 它是输入事件的第一道闸门，根据 opt 的选择过滤并转发输入。
@onready var input_router: InputRoutingViewportContainer = $InputRoutingViewportContainer
## 获取 SubViewport 内的 Player 节点（玩家角色）。
## 每个分屏对应一个独立的 Player 实例，拥有各自的位置和颜色。
@onready var play: Player = $InputRoutingViewportContainer/SubViewport/Player


## 设置该分屏的配置，并执行 OptionButton 的初始化。
## 该函数由 root.gd 在 _ready 中调用，用于统一初始化每个分屏的参数。
func set_config(config_dict: Dictionary):
	# 从配置字典中提取 "keyboard" 项（键盘配置字典），保存到本地变量。
	_keyboard_options = config_dict["keyboard"]
	# 设置该分屏内玩家的初始位置，值来自 config_dict["position"]。
	# 在 root.gd 中该位置根据分屏索引计算得出，使玩家出现在对应区域。
	play.position = config_dict["position"]
	# 从配置字典中提取 "index"（当前分屏的全局索引），并显式声明类型为 int。
	var local_index: int = config_dict["index"]
	# 设置玩家精灵的调制颜色（modulate），用于区分不同玩家的视觉外观。
	play.modulate = config_dict["color"]
	# 清空 OptionButton 中的所有现有选项，准备重新填充。
	opt.clear()
	# 遍历所有可用的键盘配置名称（如 "wasd"、"ijkl"、"arrows"、"numpad"）。
	for keyboard_opt in _keyboard_options:
		# 将每个键盘配置名称作为文本项添加到 OptionButton 下拉列表中。
		opt.add_item(keyboard_opt)
	# 遍历可用手柄的数量（joypads 为手柄数量，例如 4）。
	# index 的取值范围为 0 到 joypads-1。
	for index in config_dict["joypads"]:
		# 使用字符串格式化生成选项文本，如 "Joypad 1"、"Joypad 2"。
		# 注意 index + 1 是为了让用户看到从 1 开始计数的更直观编号。
		opt.add_item("%s %s" % [JOYPAD_PREFIX, index + 1])
	# 将 OptionButton 的当前选中项设为 local_index。
	# 这样默认情况下，第一个分屏选第 0 项，第二个分屏选第 1 项，以此类推，避免初始冲突。
	opt.select(local_index)
	# 手动调用选项选中回调函数，确保 input_router 立即应用与当前选中项对应的输入配置。
	_on_option_button_item_selected(local_index)
	# 将该 SubViewport 的 world_2d 属性指向配置字典中的共享 World2D 对象。
	# 这是实现"多窗口同世界"的关键：所有分屏看到同一个物理世界和实体状态。
	viewport.world_2d = config_dict["world"]


## 信号回调函数，当 OptionButton 的选中项改变时自动触发。
## index 参数为新选中项的索引。
func _on_option_button_item_selected(index: int) -> void:
	# 获取当前选中项的显示文本，例如 "wasd" 或 "Joypad 2"。
	var text: String = opt.get_item_text(index)
	# 判断该文本是否以 JOYPAD_PREFIX（即 "Joypad"）开头。
	# 如果是，说明玩家选择使用手柄作为输入设备。
	if text.begins_with(JOYPAD_PREFIX):
		# 构造配置字典传给 input_router：
		# - 使用 text.substr(text.length() - 1, -1) 截取字符串末尾的数字字符（如 "2"）。
		#   注意：这里 substr 的第二个参数 -1 表示截取到末尾，从而得到最后一个字符。
		# - 通过 to_int() 将字符转换为整数作为手柄设备 ID。
		# - "keyboard" 设为空数组，表示不再接受任何键盘输入。
		input_router.set_input_config({"joypad": text.substr(text.length() - 1, -1).to_int(), "keyboard": []})
	# 否则，说明玩家选择的是一套键盘配置（如 "wasd"）。
	else:
		# 从 _keyboard_options 字典中取出对应名称下的 "keys" 数组（按键码列表）。
		# 将 "keyboard" 设为该数组，允许这些按键的事件通过。
		# 将 "joypad" 设为 -1，禁止所有手柄输入事件。
		input_router.set_input_config({"keyboard": _keyboard_options[text]["keys"], "joypad": -1})
