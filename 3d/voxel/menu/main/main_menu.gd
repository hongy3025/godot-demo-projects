## 主菜单控制器。
##
## 继承自 [Control]，管理标题画面、开始游戏和选项菜单的切换。
extends Control

## 标题画面容器。
@onready var title: VBoxContainer = $TitleScreen
## 开始游戏选择容器。
@onready var start: HBoxContainer = $StartGame
## 选项子菜单。
@onready var options: Control = $Options


## 开始按钮回调。显示世界类型选择界面。
func _on_Start_pressed() -> void:
	start.visible = true
	title.visible = false


## 选项按钮回调。显示选项子菜单。
func _on_Options_pressed() -> void:
	options.prev_menu = title
	options.visible = true
	title.visible = false


## 退出按钮回调。退出游戏。
func _on_Exit_pressed() -> void:
	get_tree().quit()


## 随机方块世界按钮回调。设置世界类型为随机并加载游戏场景。
func _on_RandomBlocks_pressed() -> void:
	Settings.world_type = 0
	get_tree().change_scene_to_packed(preload("res://world/world.tscn"))


## 平坦草地世界按钮回调。设置世界类型为平坦并加载游戏场景。
func _on_FlatGrass_pressed() -> void:
	Settings.world_type = 1
	get_tree().change_scene_to_packed(preload("res://world/world.tscn"))


## 返回标题按钮回调。
func _on_BackToTitle_pressed() -> void:
	title.visible = true
	start.visible = false
