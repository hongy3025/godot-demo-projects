## 自定义资源格式保存器 —— 将 [SillyMaterialResource] 保存为 `.silly_mat_loadable` 文件。
## 继承自 [ResourceFormatSaver]，与 [SillyMatFormatLoader] 配合实现资源的读写。
## 需要在 [EditorPlugin] 中注册才能生效。
##
## 与导入器（EditorImportPlugin）的区别：
## - 保存器/加载器：资源可读写，但同一扩展名只能有一个处理器
## - 导入器：资源只读，但可在导入面板中配置，且可存在多个
##
## 本演示使用两种不同的文件扩展名来同时展示两种方式。
@tool
class_name SillyMatFormatSaver
extends ResourceFormatSaver


## 返回此保存器支持的文件扩展名列表。
## 参数 resource 可用于根据资源类型动态决定扩展名。
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["silly_mat_loadable"])


## 判断给定的 [Resource] 是否由本保存器处理。
## 仅处理 [SillyMaterialResource] 类型的资源。
func _recognize(resource: Resource) -> bool:
	return resource is SillyMaterialResource


## 执行实际的保存操作。
## 将 [SillyMaterialResource] 通过 write_to_file 方法写入文件。
##
## 参数:
##   resource: 要保存的资源对象
##   path: 保存路径
##   flags: 保存标志位
## 返回: [Error] 错误码
func _save(resource: Resource, path: String, flags: int) -> Error:
	var mat_res: SillyMaterialResource = resource as SillyMaterialResource
	if mat_res == null:
		return ERR_INVALID_DATA
	return mat_res.write_to_file(path)
