## 材质创建器插件 —— 编辑器插件主入口。
## 继承自 [EditorPlugin]，注册以下组件：
## - 资源格式加载器 [SillyMatFormatLoader]（处理 `.silly_mat_loadable` 文件加载）
## - 资源格式保存器 [SillyMatFormatSaver]（处理 `.silly_mat_loadable` 文件保存）
## - 导入插件 [ImportSillyMatAsSillyMaterialResource]（导入为自定义资源）
## - 导入插件 [ImportSillyMatAsStandardMaterial3D]（导入为标准材质）
## - 自定义停靠面板（材质创建器 UI）
@tool
extends EditorPlugin


## 材质创建器停靠面板的引用。
var _material_creator_dock: Panel
## 资源格式加载器实例。负责从 `.silly_mat_loadable` 文件加载资源。
var _silly_mat_loader := SillyMatFormatLoader.new()
## 资源格式保存器实例。负责将资源保存为 `.silly_mat_loadable` 文件。
var _silly_mat_saver := SillyMatFormatSaver.new()
## 导入插件实例：将 `.silly_mat_importable` 导入为 [SillyMaterialResource]。
var _import_as_silly_mat_res := ImportSillyMatAsSillyMaterialResource.new()
## 导入插件实例：将 `.silly_mat_importable` 导入为 [StandardMaterial3D]。
var _import_as_standard_mat := ImportSillyMatAsStandardMaterial3D.new()


## 插件进入编辑器树时调用。
## 注册加载器、保存器、导入器，并创建材质创建器停靠面板。
func _enter_tree() -> void:
	# 注册资源格式加载器和保存器
	ResourceLoader.add_resource_format_loader(_silly_mat_loader)
	ResourceSaver.add_resource_format_saver(_silly_mat_saver)
	# 注册导入插件
	add_import_plugin(_import_as_silly_mat_res)
	add_import_plugin(_import_as_standard_mat)
	# 创建材质创建器停靠面板
	const dock_scene: PackedScene = preload("res://addons/material_creator/editor/material_dock.tscn")
	_material_creator_dock = dock_scene.instantiate()
	# 将编辑器接口传递给面板，供其操作编辑器选择等
	_material_creator_dock.editor_interface = get_editor_interface()
	# 根据编辑器缩放比例调整面板大小
	var dock_scale: float = EditorInterface.get_editor_scale() * 0.85
	_material_creator_dock.custom_minimum_size *= dock_scale
	for child in _material_creator_dock.find_children("*", "Control"):
		child.custom_minimum_size *= dock_scale
	# 将面板添加到编辑器左侧停靠栏
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _material_creator_dock)


## 插件退出编辑器树时调用。
## 注销所有注册的组件并清理资源。
func _exit_tree() -> void:
	remove_control_from_docks(_material_creator_dock)
	ResourceLoader.remove_resource_format_loader(_silly_mat_loader)
	ResourceSaver.remove_resource_format_saver(_silly_mat_saver)
	remove_import_plugin(_import_as_silly_mat_res)
	remove_import_plugin(_import_as_standard_mat)
