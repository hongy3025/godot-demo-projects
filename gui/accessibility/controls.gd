## 无障碍控件演示 —— 展示 Godot 的无障碍 UI 基本用法。
## 继承自 [Control]，演示自动聚焦和实时区域（Live Region）更新。
extends Control


## _ready 入口：自动聚焦到姓名输入框。
## 无障碍 UI 应始终拥有键盘焦点，因为键盘是主要的交互方式。
func _ready() -> void:
	$LineEditName.grab_focus()


## 设置按钮点击回调：将实时区域输入框的文本设置到标签中。
func _on_button_set_pressed() -> void:
	$Panel/LabelRegion.text = $LineEditLiveReg.text
