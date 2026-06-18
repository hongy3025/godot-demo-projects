## 状态基类 —— 所有状态节点的接口基类。
## 本身不执行任何操作，但确保每个状态对象都包含以下方法。
extends Node

## 状态结束信号，传递下一个状态名称。
@warning_ignore("unused_signal")
signal finished(next_state_name: StringName)

## 进入状态时的初始化。例如切换动画。
func enter() -> void:
	pass


## 退出状态时的清理。例如重置计时器值。
func exit() -> void:
	pass


## 处理输入事件。
func handle_input(_input_event: InputEvent) -> void:
	pass


## 每帧更新逻辑。
func update(_delta: float) -> void:
	pass


## 动画播放完成回调。
func _on_animation_finished(_anim_name: String) -> void:
	pass
