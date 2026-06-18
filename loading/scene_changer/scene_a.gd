## 场景 A —— 演示使用 SceneTree.change_scene_to_file() 切换场景。
## 继承自 [Panel]，作为场景切换的 UI 面板。
## 通过 change_scene_to_file() 直接传入场景文件路径进行切换。
extends Panel


## "跳转场景"按钮的信号回调。点击后跳转到场景 B。
## 使用 change_scene_to_file() 直接传入场景文件路径，这是最简便的场景切换方式。
func _on_goto_scene_pressed() -> void:
	# 将场景切换为指定路径的场景。
	get_tree().change_scene_to_file("res://scene_b.tscn")
