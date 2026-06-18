## 场景 B —— 演示通过 autoload（自动加载）全局变量切换场景。
## 继承自 [Panel]，作为场景切换的 UI 面板。
## 通过调用 autoload 单例 `global` 的 `goto_scene()` 方法跳转到场景 A。
extends Panel


## "跳转场景"按钮的信号回调。点击后跳转到场景 A。
func _on_goto_scene_pressed() -> void:
	global.goto_scene("res://scene_a.tscn")
