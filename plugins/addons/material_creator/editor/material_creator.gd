## 材质创建器面板 —— 编辑器停靠面板的核心逻辑。
## 继承自 [Panel]，提供材质编辑的 UI 交互功能。
## 支持创建、保存、加载、导出、导入材质，以及将材质应用到选中的 [MeshInstance3D] 节点。
## 注意：类名中的 "silly" 仅为演示用途，表示名称是任意的。
@tool
extends Panel


## 编辑器接口引用，用于获取编辑器选择、文件系统等。
var editor_interface: EditorInterface

## 漫反射颜色选择器按钮。
@onready var albedo_color_picker: ColorPickerButton = $VBoxContainer/AlbedoColorPicker
## 金属度滑动条。
@onready var metallic_slider: HSlider = $VBoxContainer/MetallicSlider
## 粗糙度滑动条。
@onready var roughness_slider: HSlider = $VBoxContainer/RoughnessSlider

## 保存材质文件对话框（保存为 `.tres` 或 `.silly_mat_loadable`）。
@onready var save_material_dialog: FileDialog = $SaveMaterialDialog
## 导出材质文件对话框（导出为 `.silly_mat_importable`）。
@onready var export_material_dialog: FileDialog = $ExportMaterialDialog
## 通过导入器加载材质的文件对话框。
@onready var load_material_importer_dialog: FileDialog = $LoadMaterialImporterDialog
## 通过加载器加载材质的文件对话框。
@onready var load_material_loader_dialog: FileDialog = $LoadMaterialLoaderDialog
## 直接导入材质的文件对话框（运行时方式）。
@onready var import_material_directly_dialog: FileDialog = $ImportMaterialDirectlyDialog


## 节点就绪时调用。初始化文件对话框的默认路径和文件名。
func _ready() -> void:
	# 检查节点名是否包含空格，用于确保停靠面板标题显示正常
	if not name.contains(" "):
		printerr("Warning: Material Creator dock doesn't have a space in its node name, so it will be displayed without any spacing.")
	save_material_dialog.current_path = "res://addons/material_creator/example/"
	save_material_dialog.current_file = "new_material.silly_mat_loadable"
	export_material_dialog.current_path = "res://addons/material_creator/example/"
	export_material_dialog.current_file = "new_material.silly_mat_importable"
	load_material_importer_dialog.current_path = "res://addons/material_creator/example/"
	load_material_loader_dialog.current_path = "res://addons/material_creator/example/"
	import_material_directly_dialog.current_path = ProjectSettings.globalize_path("res://addons/material_creator/example/")
	# 启用面板裁剪，防止内容溢出
	RenderingServer.canvas_item_set_clip(get_canvas_item(), true)


## 保存或导出材质的核心函数。
## 根据文件扩展名决定保存方式：
## - `.tres`：使用 [ResourceSaver] 保存为 Godot 资源
## - `.silly_mat_loadable`：使用 [ResourceSaver] 保存（项目内）
## - 其他：使用 write_to_file 保存为 JSON 格式
##
## 参数:
##   path: 保存路径
func _save_or_export_file(path: String) -> void:
	if path.is_empty():
		printerr("Material Creator: No path chosen for saving.")
		return
	# 确保目标目录存在
	var dir: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err: Error = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			printerr("Material Creator: Can't create folder: %s (%s)" % [dir, error_string(err)])
			return
	var silly_mat: SillyMaterialResource = _create_silly_material_from_editor_values()
	var ext: String = path.get_extension().to_lower()
	var err: Error
	var is_in_project: bool = path.begins_with("res://") or path.begins_with("user://")
	if ext == "tres":
		err = ResourceSaver.save(silly_mat, path)
		if not is_in_project:
			printerr("Material Creator: Warning: When saving outside of the Godot project, "
					+ "prefer exporting instead. A Godot resource may not be functional "
					+ "without the context of its original project (ex: script paths).")
	elif ext == "silly_mat_loadable" and is_in_project:
		err = ResourceSaver.save(silly_mat, path)
	else:
		err = silly_mat.write_to_file(path)
	if err != OK:
		printerr("Material Creator: Failed to save to %s, reason: %s" % [path, error_string(err)])
	else:
		print("Material Creator: Successfully saved to ", path)
	# 通知编辑器文件系统已变更，刷新导入面板
	var efs: EditorFileSystem = editor_interface.get_resource_filesystem()
	efs.scan()


## 通过资源加载器加载文件。
## 使用 [ResourceLoader.load] 加载文件，支持 [SillyMaterialResource] 和 [StandardMaterial3D] 类型。
##
## 参数:
##   path: 文件路径
func load_file_resource_loader(path: String) -> void:
	var loaded_file: Resource = ResourceLoader.load(path)
	if loaded_file == null:
		printerr("Material Creator: Failed to load file at %s" % path)
		return
	if loaded_file is SillyMaterialResource:
		edit_silly_material(loaded_file)
		return
	if loaded_file is StandardMaterial3D:
		edit_silly_material(SillyMaterialResource.from_material(loaded_file))
		return


## 直接导入文件（运行时方式）。
## 使用 [SillyMaterialResource.read_from_file] 读取 JSON 格式文件。
##
## 参数:
##   path: 文件路径
func load_file_directly(path: String) -> void:
	var silly_mat := SillyMaterialResource.read_from_file(path)
	if silly_mat == null:
		printerr("Material Creator: Failed to directly load file at %s" % path)
	edit_silly_material(silly_mat)


## 将 [SillyMaterialResource] 的数据应用到 UI 控件上。
## 更新颜色选择器、金属度滑动条和粗糙度滑动条的值。
##
## 参数:
##   silly_mat: 要编辑的材质资源
func edit_silly_material(silly_mat: SillyMaterialResource) -> void:
	albedo_color_picker.color = silly_mat.albedo_color
	metallic_slider.value = silly_mat.metallic_strength
	roughness_slider.value = silly_mat.roughness_strength


## 从 UI 控件的当前值创建 [SillyMaterialResource]。
## 读取颜色选择器、金属度滑动条和粗糙度滑动条的值。
##
## 返回: [SillyMaterialResource] 包含当前 UI 值的新资源
func _create_silly_material_from_editor_values() -> SillyMaterialResource:
	var color: Color = albedo_color_picker.color
	var metallic: float = metallic_slider.value
	var roughness: float = roughness_slider.value
	var silly_res := SillyMaterialResource.new()
	silly_res.albedo_color = color
	silly_res.metallic_strength = metallic
	silly_res.roughness_strength = roughness
	return silly_res


## 将材质应用到选中的 [MeshInstance3D] 节点。
## 遍历选中的节点列表，对每个 [MeshInstance3D] 设置表面 0 的覆盖材质。
##
## 参数:
##   selected_nodes: 选中的节点数组
func _apply_material_to_nodes(selected_nodes: Array[Node]) -> void:
	if selected_nodes.is_empty():
		printerr("Material Creator: Can't apply the material because there are no nodes selected!")
		return
	var new_material: StandardMaterial3D = _create_silly_material_from_editor_values().to_material()
	var applied: bool = false
	for node in selected_nodes:
		if node is MeshInstance3D:
			node.set_surface_override_material(0, new_material)
			applied = true
	if applied:
		print("Material Creator: Applied material to selected MeshInstance3D nodes!")
	else:
		printerr("Material Creator: Can't apply the material because there are no MeshInstance3D nodes selected!")


## "应用"按钮点击回调。
## 通过编辑器接口获取当前选中的节点，并将材质应用到这些节点上。
func _on_apply_button_pressed() -> void:
	var editor_selection: EditorSelection = editor_interface.get_selection()
	var selected_nodes: Array[Node] = editor_selection.get_selected_nodes()
	_apply_material_to_nodes(selected_nodes)


## "保存"按钮点击回调。弹出保存文件对话框。
func _on_save_button_pressed() -> void:
	save_material_dialog.popup_centered(save_material_dialog.min_size * EditorInterface.get_editor_scale())


## "导出"按钮点击回调。弹出导出文件对话框。
func _on_export_button_pressed() -> void:
	export_material_dialog.popup_centered(export_material_dialog.min_size * EditorInterface.get_editor_scale())


## "通过导入器加载"按钮点击回调。弹出导入器加载文件对话框。
func _on_load_button_importer_pressed() -> void:
	load_material_importer_dialog.popup_centered(load_material_importer_dialog.min_size * EditorInterface.get_editor_scale())


## "通过加载器加载"按钮点击回调。弹出加载器加载文件对话框。
func _on_load_button_loader_pressed() -> void:
	load_material_loader_dialog.popup_centered(load_material_loader_dialog.min_size * EditorInterface.get_editor_scale())


## "直接导入"按钮点击回调。弹出直接导入文件对话框。
func _on_import_button_directly_pressed() -> void:
	import_material_directly_dialog.popup_centered(import_material_directly_dialog.min_size * EditorInterface.get_editor_scale())
