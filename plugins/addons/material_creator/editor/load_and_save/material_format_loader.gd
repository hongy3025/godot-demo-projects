## 自定义资源格式加载器 —— 从 `.silly_mat_loadable` 文件加载 [SillyMaterialResource]。
## 继承自 [ResourceFormatLoader]，与 [SillyMatFormatSaver] 配合实现资源的读写。
## 需要在 [EditorPlugin] 中注册才能生效。
##
## 与导入器（EditorImportPlugin）的区别：
## - 加载器/保存器：资源可读写，但同一扩展名只能有一个处理器
## - 导入器：资源只读，但可在导入面板中配置，且可存在多个
##
## 本演示使用两种不同的文件扩展名来同时展示两种方式。
@tool
class_name SillyMatFormatLoader
extends ResourceFormatLoader


## 返回此加载器支持的文件扩展名列表。
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["silly_mat_loadable"])


## 根据文件路径返回资源类型名称。
## 用于让 Godot 知道此文件对应什么资源类型。
func _get_resource_type(path: String) -> String:
	if path.get_extension() == "silly_mat_loadable":
		return "SillyMaterialResource"
	return ""


## 判断此加载器是否处理指定的资源类型。
## 参数 type_name 是资源类型名称（如 "SillyMaterialResource"）。
func _handles_type(type_name: StringName) -> bool:
	return type_name == &"SillyMaterialResource"


## 执行实际的加载操作。
## 使用 [SillyMaterialResource.read_from_file] 从文件读取并解析资源。
##
## 参数:
##   path: 文件路径
##   original_path: 原始路径（通常与 path 相同）
##   use_sub_threads: 是否使用子线程加载
##   cache_mode: 缓存模式
## 返回: [Variant] 加载的资源对象，失败时返回 null
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	return SillyMaterialResource.read_from_file(original_path)
