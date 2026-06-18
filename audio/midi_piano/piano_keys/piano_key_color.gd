## 钢琴键颜色区域 —— 处理钢琴键的鼠标点击输入。
##
## 继承自 [ColorRect]，作为钢琴键的子节点存在。
## 这个脚本存在的唯一目的就是将鼠标点击事件转发给父节点 [PianoKey]。
extends ColorRect

## 父节点（PianoKey）引用，通过 @onready 在节点就绪时自动获取。
@onready var parent: PianoKey = get_parent()

## 处理 GUI 输入事件：鼠标点击时激活父节点的钢琴键。
func _gui_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.pressed:
		parent.activate()
