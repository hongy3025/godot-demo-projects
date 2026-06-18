## 自定义节点插件 —— 在编辑器中注册自定义节点类型 "Heart"。
## 继承自 [EditorPlugin]，演示如何使用 add_custom_type 创建自定义节点。
## 注册的自定义节点可以在编辑器的"添加节点"面板中直接使用。
@tool
extends EditorPlugin


## 插件进入编辑器树时调用。
## 注册名为 "Heart" 的自定义节点类型，继承自 [Node2D]，
## 使用 heart.gd 作为脚本，heart.png 作为图标。
func _enter_tree() -> void:
	var icon: Texture2D = preload("res://addons/custom_node/heart.png")
	add_custom_type("Heart", "Node2D", preload("res://addons/custom_node/heart.gd"), icon)


## 插件退出编辑器树时调用。
## 移除 "Heart" 自定义节点类型的注册。
func _exit_tree() -> void:
	remove_custom_type("Heart")
