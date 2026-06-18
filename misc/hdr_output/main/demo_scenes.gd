## HDR 演示场景选择器 —— 切换显示不同的 HDR 演示子场景。
##
## 继承自 [Node]，管理一组 Control 场景的可见性。
extends Node

## 演示场景数组
@export var scenes: Array[Control]


## _ready 入口，默认显示第一个场景。
func _ready() -> void:
	_on_demo_scene_item_selected(0)


## 演示场景选择回调，只显示选中索引的场景。
func _on_demo_scene_item_selected(index: int) -> void:
	for i in range(scenes.size()):
		scenes[i].visible = i == index
