## 主屏幕插件 —— 在编辑器中添加自定义主屏幕。
## 继承自 [EditorPlugin]，演示如何创建和管理编辑器主屏幕。
## 主屏幕是编辑器顶部标签页切换的独立工作区（如 2D、3D、脚本等）。
@tool
extends EditorPlugin


## 主面板场景的预加载引用。
const MainPanel = preload("res://addons/main_screen/main_panel.tscn")

## 主面板实例的引用。类型为 [CenterContainer]。
var main_panel_instance: CenterContainer


## 插件进入编辑器树时调用。
## 实例化主面板并添加到编辑器主视口，初始状态为隐藏。
func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	# 将主面板添加到编辑器的主屏幕区域
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	# 初始时隐藏主面板（必须调用）
	_make_visible(false)


## 插件退出编辑器树时调用。
## 释放主面板实例。
func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()


## 返回插件是否拥有主屏幕。
## 返回 true 表示此插件会占用一个主屏幕标签页。
func _has_main_screen() -> bool:
	return true


## 控制主面板的显示/隐藏。
## 当用户切换到该插件的主屏幕时，Godot 会调用此方法。
##
## 参数:
##   visible: true 表示显示，false 表示隐藏
func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible


## 判断此插件是否处理指定对象。
## 用于在编辑器中双击对象时，自动切换到对应的主屏幕。
## 如果插件不处理任何节点类型，可以移除该方法。
func _handles(object: Object) -> bool:
	return is_instance_of(object, preload("res://addons/main_screen/handled_by_main_screen.gd"))


## 返回插件主屏幕的显示名称，显示在编辑器顶部的标签页上。
func _get_plugin_name() -> String:
	return "Main Screen Plugin"


## 返回插件主屏幕的图标。
## 此处复用编辑器内置的 "Node" 图标。
func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon(&"Node", &"EditorIcons")
