## 状态栈显示器 —— 调试用面板，显示当前状态栈内容。
## 继承自 Panel，实时显示状态栈中所有状态的名称和索引。
extends Panel

## 状态机节点引用。
@onready var fsm_node: Node = get_node(^"../../Player/StateMachine")

## 每帧更新状态栈显示。
func _process(_delta: float) -> void:
	var states_names: String = ""
	var numbers: String = ""
	var index := 0

	for state: Node in fsm_node.states_stack:
		states_names += String(state.name) + "\n"
		numbers += str(index) + "\n"
		index += 1

	%States.text = states_names
	%Numbers.text = numbers
