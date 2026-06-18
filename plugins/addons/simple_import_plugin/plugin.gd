## 简单导入插件 —— 编辑器插件入口。
## 继承自 [EditorPlugin]，负责注册和注销自定义导入插件。
## 演示了如何为 Godot 编辑器添加一个自定义资源导入器。
@tool
extends EditorPlugin


## 自定义导入插件的实例引用。
## 类型为 [EditorImportPlugin]，在 _enter_tree 中创建并注册。
var import_plugin: EditorImportPlugin


## 插件进入编辑器树时调用。
## 创建 [ImportPlugin] 实例并通过 add_import_plugin 注册到编辑器。
func _enter_tree() -> void:
	import_plugin = preload("import.gd").new()
	add_import_plugin(import_plugin)


## 插件退出编辑器树时调用。
## 通过 remove_import_plugin 注销导入插件并释放引用。
func _exit_tree() -> void:
	remove_import_plugin(import_plugin)
	import_plugin = null
