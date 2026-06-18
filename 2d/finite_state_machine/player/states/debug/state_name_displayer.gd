## 状态名称显示器 —— 调试用，显示当前状态名称。
## 继承自 Label，跟随角色移动并实时更新文本。
extends Label

## 标签的起始位置偏移。
var start_position := Vector2()

func _ready() -> void:
	start_position = position


## 每帧更新标签位置，跟随 BodyPivot 移动。
func _physics_process(_delta: float) -> void:
	position = $"../BodyPivot".position + start_position


## 状态机状态变化时更新标签文本。
func _on_StateMachine_state_changed(current_state: Node) -> void:
	text = String(current_state.name)
