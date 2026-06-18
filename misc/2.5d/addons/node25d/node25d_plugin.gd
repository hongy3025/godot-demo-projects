## 2.5D 编辑器插件入口 —— 注册自定义节点类型和编辑器主面板。
##
## 在 Godot 编辑器中添加 "2.5D" 主屏幕，包含视角切换、缩放控制等功能。
## 注册三个自定义类型: Node25D、YSort25D、ShadowMath25D。
@tool
extends EditorPlugin


## 编辑器主面板场景预加载
const MainPanel = preload("res://addons/node25d/main_screen/main_screen_25d.tscn")

# 主面板实例
var main_panel_instance: VBoxContainer


## _enter_tree 入口，插件启用时初始化主面板并注册自定义节点类型。
func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	# 将编辑器接口引用传递给主面板（第二个子节点是 Viewport25D）
	main_panel_instance.get_child(1).editor_interface = get_editor_interface()

	# 将主面板添加到编辑器的主屏幕区域
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

	# 默认隐藏主面板
	_make_visible(false)
	# 注册自定义节点类型，使其出现在 "添加节点" 面板中
	add_custom_type("Node25D", "Node2D", preload("node_25d.gd"), preload("icons/node_25d_icon.png"))
	add_custom_type("YSort25D", "Node", preload("y_sort_25d.gd"), preload("icons/y_sort_25d_icon.png"))
	add_custom_type("ShadowMath25D", "CharacterBody3D", preload("shadow_math_25d.gd"), preload("icons/shadow_math_25d_icon.png"))


## _exit_tree 入口，插件卸载时清理主面板并移除自定义节点类型。
func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()
	# 插件卸载时移除自定义类型
	remove_custom_type("ShadowMath25D")
	remove_custom_type("YSort25D")
	remove_custom_type("Node25D")


## 声明插件拥有主屏幕面板。
func _has_main_screen() -> bool:
	return true


## 控制主面板的显隐。
func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		if visible:
			main_panel_instance.show()
		else:
			main_panel_instance.hide()


## 返回插件主屏幕的名称。
func _get_plugin_name() -> String:
	return "2.5D"


## 返回插件主屏幕的图标。
func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/node25d/icons/viewport_25d.svg")


## 判断编辑器是否应处理该对象的选中状态（仅处理 Node25D 类型）。
func _handles(obj: Object) -> bool:
	return obj is Node25D
