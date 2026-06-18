## 2.5D 编辑器插件 —— 注册自定义节点类型和主屏幕。
##
## 继承自 [EditorPlugin]，是 Godot 编辑器插件的基类。
## 功能：
##   1. 在编辑器中注册 3 种自定义节点类型：Node25D、YSort25D、ShadowMath25D
##   2. 添加一个名为 "2.5D" 的主屏幕，用于 2.5D 场景编辑
##   3. 管理主屏幕面板的生命周期（创建/销毁）
## @tool 注解使插件在编辑器中运行
@tool
extends EditorPlugin

## 主屏幕场景的预加载资源
## 使用 const 关键字在编译时加载，提高性能
const MainPanel = preload("res://addons/node25d-cs/main_screen/main_screen_25d.tscn")

## 主屏幕面板的实例引用
## 在 _enter_tree 中创建，在 _exit_tree 中销毁
var main_panel_instance


## 插件进入编辑器场景树时调用，进行初始化。
##
## 功能：
##   1. 实例化主屏幕面板
##   2. 将主屏幕面板添加到编辑器的主视口中
##   3. 隐藏主屏幕面板（默认不显示）
##   4. 注册 3 种自定义节点类型（Node25D、YSort25D、ShadowMath25D）
##
## 核心逻辑：
##   add_custom_type 用于在编辑器中注册新的节点类型，
##   参数依次为：类型名称、基类类型、脚本资源、图标资源。
func _enter_tree():
	# 实例化主屏幕面板
	main_panel_instance = MainPanel.instantiate()
	# 设置编辑器接口引用（供 C# 脚本使用）
	# main_panel_instance.get_child(1).set("editorInterface", get_editor_interface()) # For C#
	main_panel_instance.get_child(1).editor_interface = get_editor_interface()

	# 将主屏幕面板添加到编辑器的主视口中
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)

	# 默认隐藏主屏幕面板
	make_visible(false)

	# 注册自定义节点类型
	# add_custom_type(名称, 基类, 脚本, 图标)
	add_custom_type("Node25D", "Node2D", preload("Node25D.cs"), preload("icons/node_25d_icon.png"))
	add_custom_type("YSort25D", "Node", preload("YSort25D.cs"), preload("icons/y_sort_25d_icon.png"))
	add_custom_type("ShadowMath25D", "CharacterBody3D", preload("ShadowMath25D.cs"), preload("icons/shadow_math_25d_icon.png"))


## 插件退出编辑器场景树时调用，进行清理。
##
## 功能：
##   1. 释放主屏幕面板实例
##   2. 移除已注册的自定义节点类型
##
## 注意：
##   remove_custom_type 的调用顺序与 add_custom_type 无关，
##   但建议保持对应关系以便维护。
func _exit_tree():
	# 释放主屏幕面板
	main_panel_instance.queue_free()

	# 移除自定义节点类型
	remove_custom_type("ShadowMath25D")
	remove_custom_type("YSort25D")
	remove_custom_type("Node25D")


## 判断插件是否拥有主屏幕。
##
## 返回 true 表示该插件提供了一个独立的主屏幕标签页，
## 会在编辑器顶部工具栏中显示一个 "2.5D" 按钮。
func has_main_screen():
	return true


## 控制主屏幕面板的显示/隐藏。
##
## 参数：
##   visible: true 显示面板，false 隐藏面板
func make_visible(visible):
	if visible:
		main_panel_instance.show()
	else:
		main_panel_instance.hide()


## 获取插件名称，显示在编辑器主屏幕按钮上。
##
## 返回: [String] 插件名称 "2.5D"
func get_plugin_name():
	return "2.5D"


## 获取插件图标，显示在编辑器主屏幕按钮上。
##
## 返回: [Texture2D] 图标纹理资源
func get_plugin_icon():
	return preload("res://addons/node25d-cs/icons/viewport_25d.svg")
