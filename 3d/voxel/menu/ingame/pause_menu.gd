## 游戏内暂停菜单控制器。
##
## 继承自 [Control]，管理暂停菜单的显示/隐藏和子菜单切换。
extends Control

## 准星节点。
@onready var crosshair: CenterContainer = $Crosshair
## 暂停菜单容器。
@onready var pause: VBoxContainer = $Pause
## 选项子菜单。
@onready var options: Control = $Options
## VoxelWorld 引用。
@onready var voxel_world: Node = $"../VoxelWorld"

## _process 入口。处理暂停键切换。
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		pause.visible = crosshair.visible
		crosshair.visible = not crosshair.visible
		options.visible = false
		if crosshair.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## 继续游戏按钮回调。
func _on_Resume_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crosshair.visible = true
	pause.visible = false


## 选项按钮回调。显示选项子菜单。
func _on_Options_pressed() -> void:
	options.prev_menu = pause
	options.visible = true
	pause.visible = false


## 主菜单按钮回调。清理体素世界并返回主菜单。
func _on_MainMenu_pressed() -> void:
	voxel_world.clean_up()
	get_tree().change_scene_to_packed(load("res://menu/main/main_menu.tscn"))


## 退出按钮回调。清理体素世界并退出游戏。
func _on_Exit_pressed() -> void:
	voxel_world.clean_up()
	get_tree().quit()
