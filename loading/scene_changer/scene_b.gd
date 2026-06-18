## 场景 B —— 演示使用 SceneTree.change_scene_to_packed() 切换场景。
## 继承自 [Panel]，作为场景切换的 UI 面板。
## 通过 load() 预加载场景为 PackedScene，然后使用 change_scene_to_packed() 切换。
extends Panel


## "跳转场景"按钮的信号回调。点击后跳转到场景 A。
## 核心逻辑: 先用 load() 将场景文件加载为 PackedScene 对象，再通过 change_scene_to_packed() 切换。
## 这种方式比 change_scene_to_file() 更灵活，例如可以在另一个线程中加载场景，
## 或使用未保存为文件的场景。
func _on_goto_scene_pressed() -> void:
	# 将场景切换为指定的 PackedScene。
	# 虽然通常需要更多代码，但这种方式有优势，例如可以在另一个线程中加载场景，
	# 或使用未保存为文件的场景。
	var scene: PackedScene = load("res://scene_a.tscn")
	get_tree().change_scene_to_packed(scene)
