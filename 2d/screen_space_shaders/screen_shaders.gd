## 屏幕空间着色器演示控制器。
## 继承自 Control，通过下拉菜单切换显示不同的图片和着色器效果。
extends Control

## 效果选择下拉菜单。
@onready var effect: OptionButton = $Effect
## 效果容器，包含所有着色器效果节点。
@onready var effects: Control = $Effects
## 图片选择下拉菜单。
@onready var picture: OptionButton = $Picture
## 图片容器，包含所有可选图片节点。
@onready var pictures: Control = $Pictures

## 初始化时填充下拉菜单选项。
func _ready() -> void:
	# 遍历图片容器子节点，将名称添加到图片选择菜单
	for c in pictures.get_children():
		picture.add_item("PIC: " + String(c.get_name()))
	# 遍历效果容器子节点，将名称添加到效果选择菜单
	for c in effects.get_children():
		effect.add_item("FX: " + String(c.get_name()))


## 图片选择变化时，显示选中图片并隐藏其他。
func _on_picture_item_selected(id: int) -> void:
	for c in pictures.get_child_count():
		if id == c:
			pictures.get_child(c).show()
		else:
			pictures.get_child(c).hide()


## 效果选择变化时，显示选中效果并隐藏其他。
func _on_effect_item_selected(id: int) -> void:
	for c in effects.get_child_count():
		if id == c:
			effects.get_child(c).show()
		else:
			effects.get_child(c).hide()
