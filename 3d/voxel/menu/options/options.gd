## 通用选项菜单控制器 —— 支持返回上一级菜单。
##
## 继承自 [Control]，通过 prev_menu 引用实现菜单导航。
extends Control

## 上一级菜单的引用。
var prev_menu: Control

## 返回按钮回调。隐藏当前菜单并显示上一级菜单。
func _on_Back_pressed() -> void:
	prev_menu.visible = true
	visible = false
