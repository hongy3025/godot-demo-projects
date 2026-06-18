## 主屏幕插件中的"打印问候"按钮。
## 继承自 [Button]，点击时在输出面板打印问候消息。
## 演示了主屏幕插件中的 UI 交互。
@tool
extends Button


## 按钮点击回调。在 Godot 编辑器的输出面板打印问候消息。
func _on_PrintHello_pressed() -> void:
	print("Hello from the main screen plugin!")
