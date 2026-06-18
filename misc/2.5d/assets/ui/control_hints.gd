## 控制提示显隐控制 —— 按 H 键切换 HUD 提示的可见性。
##
## 继承自 [Control]，作为 CanvasLayer 的子节点存在。
## 监听输入事件，当玩家按下"切换控制提示"按键时切换自身可见性。
extends Control


## _input 入口，监听输入事件切换控制提示的可见性。
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_control_hints"):
		visible = not visible
