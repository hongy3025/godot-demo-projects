## 愚蠢材质资源 —— 演示 Godot 资源系统的多种使用方式。
## 继承自 [Resource]，支持导入、导出、加载、保存等多种操作。
##
## 功能概览：
## - 编辑器导入为 [SillyMaterialResource]（使用 ImportSillyMatAsSillyMaterialResource）
## - 编辑器导入为 [StandardMaterial3D]（使用 ImportSillyMatAsStandardMaterial3D）
## - 编辑器加载/保存（使用 SillyMatFormatLoader / SillyMatFormatSaver）
## - 运行时导入/导出（使用 read_from_file / write_to_file）
##
## 文件扩展名约定：
## - `.silly_mat_importable`：用于编辑器导入（只读）
## - `.silly_mat_loadable`：用于编辑器加载/保存（可读写）
@tool
class_name SillyMaterialResource
extends Resource


## 漫反射颜色。使用 @export 使其在检查器中可见，并可被资源序列化。
@export var albedo_color: Color = Color.BLACK
## 金属度。控制材质反射金属感强度，范围 0.0-1.0。
@export var metallic_strength: float = 0.0
## 粗糙度。控制材质表面粗糙程度，范围 0.0-1.0。
@export var roughness_strength: float = 0.0


## 从 JSON 字典创建 [SillyMaterialResource]。
## 用于运行时导入：将 JSON 格式的数据解析为资源对象。
##
## 参数:
##   json_dictionary: 包含材质数据的字典（键：albedo_color, metallic_strength, roughness_strength）
## 返回: [SillyMaterialResource] 新创建的资源实例
static func from_json_dictionary(json_dictionary: Dictionary) -> SillyMaterialResource:
	var ret := SillyMaterialResource.new()
	# 注意：实际项目中应检查键是否存在、值类型是否正确等。
	# 此处为简化演示省略了这些校验。
	var albedo_array: Array = json_dictionary["albedo_color"]
	ret.albedo_color.r = albedo_array[0]
	ret.albedo_color.g = albedo_array[1]
	ret.albedo_color.b = albedo_array[2]
	ret.metallic_strength = json_dictionary["metallic_strength"]
	ret.roughness_strength = json_dictionary["roughness_strength"]
	return ret


## 将 [SillyMaterialResource] 转换为 JSON 字典。
## 用于运行时导出：将资源数据序列化为可保存的字典格式。
## 配合 from_material 使用可实现 [StandardMaterial3D] 的运行时导出。
func to_json_dictionary() -> Dictionary:
	return {
		"albedo_color": [albedo_color.r, albedo_color.g, albedo_color.b],
		"metallic_strength": metallic_strength,
		"roughness_strength": roughness_strength,
	}


## 从 [StandardMaterial3D] 创建 [SillyMaterialResource]。
## 将 Godot 标准材质的数据复制到自定义资源中。
##
## 参数:
##   mat: 源 [StandardMaterial3D] 对象
## 返回: [SillyMaterialResource] 包含相同材质数据的新资源
static func from_material(mat: StandardMaterial3D) -> SillyMaterialResource:
	var ret := SillyMaterialResource.new()
	ret.albedo_color = mat.albedo_color
	ret.metallic_strength = mat.metallic
	ret.roughness_strength = mat.roughness
	return ret


## 将 [SillyMaterialResource] 转换为 [StandardMaterial3D]。
## 用于将自定义资源应用到 3D 网格上。
##
## 返回: [StandardMaterial3D] 新创建的标准材质
func to_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo_color
	mat.metallic = metallic_strength
	mat.roughness = roughness_strength
	return mat


## 从文件读取 JSON 数据并创建 [SillyMaterialResource]。
## 是 from_json_dictionary 的文件操作封装。
##
## 参数:
##   path: 文件路径
## 返回: [SillyMaterialResource] 或 null（读取失败时）
static func read_from_file(path: String) -> SillyMaterialResource:
	var mat_file := FileAccess.open(path, FileAccess.READ)
	if mat_file == null:
		return null
	var json_dict: Dictionary = JSON.parse_string(mat_file.get_as_text())
	return from_json_dictionary(json_dict)


## 将 [SillyMaterialResource] 以 JSON 格式写入文件。
## 是 to_json_dictionary 的文件操作封装。
##
## 参数:
##   path: 保存路径
## 返回: [Error] 错误码，OK 表示成功
func write_to_file(path: String) -> Error:
	var mat_file := FileAccess.open(path, FileAccess.WRITE)
	if mat_file == null:
		return ERR_CANT_OPEN
	var json_dict: Dictionary = to_json_dictionary()
	mat_file.store_string(JSON.stringify(json_dict))
	mat_file.store_string("\n")
	return OK
