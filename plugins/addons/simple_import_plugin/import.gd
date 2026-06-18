## 简单导入插件 —— 自定义资源导入器。
## 继承自 [EditorImportPlugin]，实现将 `.mtxt` 文本文件导入为 [StandardMaterial3D]。
## 支持一个导入选项 "use_red_anyway"（强制使用红色）。
## 文件格式：一行文本，三个逗号分隔的整数（RGB 值，范围 0-255）。
@tool
extends EditorImportPlugin


## 预设枚举。此示例只有一个默认预设。
enum Preset {
	PRESET_DEFAULT,
}


## 返回导入器的唯一标识名称。
## 用于在 Godot 内部区分不同的导入器。
func _get_importer_name() -> String:
	return "demos.mtxt"


## 返回导入器在导入面板中显示的名称。
func _get_visible_name() -> String:
	return "Silly Material"


## 返回此导入器支持的文件扩展名列表。
## 此处为 `.mtxt` 文件。
func _get_recognized_extensions() -> PackedStringArray:
	return ["mtxt"]


## 返回导入后保存的文件扩展名。
## `.res` 是 Godot 资源文件的标准扩展名。
func _get_save_extension() -> String:
	return "res"


## 返回导入后生成的资源类型。
## 此处为 [Material]，实际保存的是 [StandardMaterial3D]。
func _get_resource_type() -> String:
	return "Material"


## 返回预设数量。
func _get_preset_count() -> int:
	return Preset.size()


## 返回指定预设的显示名称。
func _get_preset_name(preset: Preset) -> String:
	match preset:
		Preset.PRESET_DEFAULT:
			return "Default"
		_:
			return "Unknown"


## 返回指定预设的导入选项列表。
## 每个选项是一个 Dictionary，包含 name（选项名）和 default_value（默认值）。
## 此处提供一个 "use_red_anyway" 布尔选项。
func _get_import_options(_path: String, preset: Preset) -> Array[Dictionary]:
	match preset:
		Preset.PRESET_DEFAULT:
			return [{
				"name": "use_red_anyway",
				"default_value": false,
			}]
		_:
			return []


## 返回导入顺序优先级。
## 使用默认导入顺序。
func _get_import_order() -> int:
	return ResourceImporter.IMPORT_ORDER_DEFAULT


## 返回指定选项在导入面板中是否可见。
## 此示例中所有选项始终可见。
func _get_option_visibility(path: String, option: StringName, options: Dictionary) -> bool:
	return true


## 核心导入函数 —— 执行实际的导入逻辑。
## 从源文件读取 RGB 值，创建 [StandardMaterial3D] 并保存。
##
## 参数:
##   source_file: 源文件路径
##   save_path: 保存路径（不含扩展名）
##   options: 导入选项字典
##   r_platform_variants: 平台变体数组（引用传递）
##   r_gen_files: 生成的文件数组（引用传递）
## 返回: [Error] 错误码，OK 表示成功
func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	# 打开源文件并读取第一行
	var file := FileAccess.open(source_file, FileAccess.READ)
	var line := file.get_line()

	# 按逗号分割 RGB 值
	var channels := line.split(",")
	if channels.size() != 3:
		return ERR_PARSE_ERROR

	# 从 RGB 值创建颜色
	var color := Color8(int(channels[0]), int(channels[1]), int(channels[2]))
	# 创建标准 3D 材质
	var material := StandardMaterial3D.new()

	# 如果开启了 "use_red_anyway" 选项，强制使用红色
	if options.use_red_anyway:
		color = Color8(255, 0, 0)

	# 设置材质的漫反射颜色
	material.albedo_color = color

	# 保存材质到导入路径
	return ResourceSaver.save(material, "%s.%s" % [save_path, _get_save_extension()])
