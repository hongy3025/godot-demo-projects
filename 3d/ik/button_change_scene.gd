## 场景切换按钮 —— 点击后切换到指定场景。
##
## 继承自 [Button]，通过导出属性指定目标场景路径，点击时切换场景。
extends Button

## 目标场景的文件路径。
@export_file var scene_to_change_to: String = ""


## _ready 入口。连接按钮的 pressed 信号。
func _ready():
	pressed.connect(change_scene)


## 切换场景到指定路径。
func change_scene():
	if not scene_to_change_to.is_empty():
		get_tree().change_scene_to_file(scene_to_change_to)
