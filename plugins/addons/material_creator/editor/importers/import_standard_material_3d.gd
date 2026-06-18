## 导入插件 —— 将 `.silly_mat_importable` 文件导入为 [StandardMaterial3D]。
## 继承自 [EditorImportPlugin]，需要在 [EditorPlugin] 中注册才能生效。
##
## 与加载器（ResourceFormatLoader）的区别：
## - 导入器：可在导入面板中配置选项，且可存在多个
## - 加载器：资源可读写，但同一扩展名只能有一个
##
## 本演示使用两种不同的文件扩展名来同时展示两种方式。
@tool
class_name ImportSillyMatAsStandardMaterial3D
extends EditorImportPlugin


## 返回导入器的唯一标识名称。
func _get_importer_name() -> String:
	return "demos.silly_material_importable.standard_material_3d"


## 返回导入器在导入面板中显示的名称。
func _get_visible_name() -> String:
	return "Standard Material 3D"


## 返回此导入器支持的文件扩展名列表。
func _get_recognized_extensions() -> PackedStringArray:
	return ["silly_mat_importable"]


## 返回导入后保存的文件扩展名。
func _get_save_extension() -> String:
	return "res"


## 返回导入后生成的资源类型。
func _get_resource_type() -> String:
	return "StandardMaterial3D"


## 返回预设数量。此导入器没有预设。
func _get_preset_count() -> int:
	return 0


## 返回指定预设的显示名称。
func _get_preset_name(preset: int) -> String:
	return "Default"


## 返回导入选项列表。
## 提供一个 "make_more_red" 布尔选项，使材质颜色更红。
func _get_import_options(_path: String, preset: int) -> Array[Dictionary]:
	var ret: Array[Dictionary] = [
		{
			"name": "make_more_red",
			"default_value": false,
		}
	]
	return ret


## 返回导入顺序优先级。
func _get_import_order() -> int:
	return ResourceImporter.IMPORT_ORDER_DEFAULT


## 返回指定选项在导入面板中是否可见。
func _get_option_visibility(path: String, option: StringName, options: Dictionary) -> bool:
	return true


## 核心导入函数 —— 执行实际的导入逻辑。
## 读取 `.silly_mat_importable` 文件，转换为 [StandardMaterial3D] 并保存。
##
## 参数:
##   source_file: 源文件路径
##   save_path: 保存路径（不含扩展名）
##   options: 导入选项字典
##   r_platform_variants: 平台变体数组（引用传递）
##   r_gen_files: 生成的文件数组（引用传递）
## 返回: [Error] 错误码
func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	var silly_mat_res := SillyMaterialResource.read_from_file(source_file)
	# 如果开启了 "make_more_red" 选项，将颜色向红色插值 50%
	if options.has("make_more_red") and options["make_more_red"]:
		silly_mat_res.albedo_color = silly_mat_res.albedo_color.lerp(Color.RED, 0.5)
	var standard_mat: StandardMaterial3D = silly_mat_res.to_material()
	# 保存到 Godot 的导入缓存目录，如 `res://.godot/imported/something.res`
	var imported_path: String = "%s.%s" % [save_path, _get_save_extension()]
	return ResourceSaver.save(standard_mat, imported_path)
