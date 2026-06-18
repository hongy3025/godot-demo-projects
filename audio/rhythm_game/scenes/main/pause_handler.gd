## 暂停处理器 —— 独立处理暂停逻辑。
##
## 由于暂停逻辑需要以 [code]PROCESS_MODE_ALWAYS[/code] 模式运行
## （即使游戏暂停也要检测暂停键输入），因此将其分离到独立节点。
extends Node


## 每帧检测暂停键输入，切换游戏暂停状态。
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		get_tree().paused = not get_tree().paused
		$"../Control/PauseLabel".visible = get_tree().paused
