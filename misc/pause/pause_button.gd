## 暂停演示 —— 暂停/继续按钮。
##
## 继承自 [Button]，点击切换 SceneTree 的暂停状态。
## 通过设置 process_mode = PROCESS_MODE_ALWAYS 确保自身在暂停时仍能响应。
extends Button


## _ready 入口，设置按钮的处理模式为始终处理，避免暂停后无法响应。
func _ready() -> void:
	# 确保此节点在暂停时仍能处理输入，否则无法恢复游戏
	# 也可以通过检查器设置此属性
	process_mode = Node.PROCESS_MODE_ALWAYS


## 按钮切换回调，暂停或恢复 SceneTree。
func _toggled(is_button_pressed: bool) -> void:
	# 根据按钮状态暂停或恢复 SceneTree
	get_tree().paused = is_button_pressed
	if is_button_pressed:
		text = "Unpause"
	else:
		text = "Pause"
