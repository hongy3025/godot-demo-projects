## 主题覆盖演示 —— 展示如何在运行时修改 StyleBox 和主题属性。
## 继承自 [Control]，演示通过 add_theme_stylebox_override 和 add_theme_color_override
## 动态修改按钮的边框颜色和标签的字体颜色。
## 注意：自定义主题项属性不属于常规的 Object 属性，应使用 add_theme_stylebox_override
## 而非 set("custom_styles/normal", ...)。
extends Control

## 标签节点引用。
@onready var label: Label = $Panel/MarginContainer/VBoxContainer/Label
## 按钮1节点引用。
@onready var button: Button = $Panel/MarginContainer/VBoxContainer/Button
## 按钮2节点引用。
@onready var button2: Button = $Panel/MarginContainer/VBoxContainer/Button2
## 重置按钮节点引用。
@onready var reset_all_button: Button = $Panel/MarginContainer/VBoxContainer/ResetAllButton


## _ready 入口：自动聚焦第一个按钮，方便键盘/手柄导航。
func _ready() -> void:
	button.grab_focus()


## 按钮1点击回调：修改按钮1的边框颜色为黄色，标签字体颜色为黄色。
## 需要同时修改 normal、hover 和 pressed 三种状态的样式盒，以确保悬停和按下时外观正确。
## 不能对所有状态使用同一个 StyleBox，因为它们有不同的背景颜色。
func _on_button_pressed() -> void:
	var new_stylebox_normal: StyleBoxFlat = button.get_theme_stylebox(&"normal").duplicate()
	new_stylebox_normal.border_color = Color(1, 1, 0)
	var new_stylebox_hover: StyleBoxFlat = button.get_theme_stylebox(&"hover").duplicate()
	new_stylebox_hover.border_color = Color(1, 1, 0)
	var new_stylebox_pressed: StyleBoxFlat = button.get_theme_stylebox(&"pressed").duplicate()
	new_stylebox_pressed.border_color = Color(1, 1, 0)

	button.add_theme_stylebox_override(&"normal", new_stylebox_normal)
	button.add_theme_stylebox_override(&"hover", new_stylebox_hover)
	button.add_theme_stylebox_override(&"pressed", new_stylebox_pressed)

	label.add_theme_color_override(&"font_color", Color(1, 1, 0.375))


## 按钮2点击回调：修改按钮2的边框颜色为青色，标签字体颜色为青色。
func _on_button2_pressed() -> void:
	var new_stylebox_normal: StyleBoxFlat = button2.get_theme_stylebox(&"normal").duplicate()
	new_stylebox_normal.border_color = Color(0, 1, 0.5)
	var new_stylebox_hover: StyleBoxFlat = button2.get_theme_stylebox(&"hover").duplicate()
	new_stylebox_hover.border_color = Color(0, 1, 0.5)
	var new_stylebox_pressed: StyleBoxFlat = button2.get_theme_stylebox(&"pressed").duplicate()
	new_stylebox_pressed.border_color = Color(0, 1, 0.5)

	button2.add_theme_stylebox_override(&"normal", new_stylebox_normal)
	button2.add_theme_stylebox_override(&"hover", new_stylebox_hover)
	button2.add_theme_stylebox_override(&"pressed", new_stylebox_pressed)

	label.add_theme_color_override(&"font_color", Color(0.375, 1, 0.75))


## 重置按钮点击回调：移除所有按钮和标签的主题覆盖，恢复默认样式。
func _on_reset_all_button_pressed() -> void:
	button.remove_theme_stylebox_override(&"normal")
	button.remove_theme_stylebox_override(&"hover")
	button.remove_theme_stylebox_override(&"pressed")

	button2.remove_theme_stylebox_override(&"normal")
	button2.remove_theme_stylebox_override(&"hover")
	button2.remove_theme_stylebox_override(&"pressed")

	label.remove_theme_color_override(&"font_color")
