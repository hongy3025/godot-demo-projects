@tool
## SADE IK 插件主入口 —— 注册自定义 IK 节点类型。
##
## 继承自 [EditorPlugin]，在编辑器中注册 IK_LookAt 和 IK_FABRIK 两种自定义节点类型。
extends EditorPlugin

## _enter_tree 入口。注册自定义节点类型。
func _enter_tree():
	add_custom_type("IK_LookAt", "Node3D", preload("ik_look_at.gd"), preload("ik_look_at.png"))
	add_custom_type("IK_FABRIK", "Node3D", preload("ik_fabrik.gd"), preload("ik_fabrik.png"))


## _exit_tree 入口。移除自定义节点类型。
func _exit_tree():
	remove_custom_type("IK_LookAt")
	remove_custom_type("IK_FABRIK")
