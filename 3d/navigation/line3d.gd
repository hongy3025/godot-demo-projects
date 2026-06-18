## 3D 路径线绘制工具 —— 使用 ImmediateMesh 在 3D 空间中绘制路径点线。
##
## 继承自 [MeshInstance3D]，通过 ImmediateMesh 动态绘制路径点序列。
## 支持绘制起点/终点标记（点）和完整路径（线段）。
class_name Line3D
extends MeshInstance3D


## _ready 入口。初始化 ImmediateMesh 和材质。
func _ready() -> void:
	mesh = ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	set_material_override(material)


## 绘制路径。清除旧绘制内容并重新绘制起点、终点和路径线段。
##
## 参数:
##   path: 路径点数组
##
## 绘制内容：
## 1. 起点和终点作为独立点（PRIMITIVE_POINTS）
## 2. 完整路径作为线段（PRIMITIVE_LINE_STRIP）
func draw_path(path: PackedVector3Array) -> void:
	var im: ImmediateMesh = mesh
	im.clear_surfaces()
	# 绘制起点和终点标记。
	im.surface_begin(Mesh.PRIMITIVE_POINTS, null)
	im.surface_add_vertex(path[0])
	im.surface_add_vertex(path[path.size() - 1])
	im.surface_end()
	# 绘制完整路径线段。
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for current_vector in path:
		im.surface_add_vertex(current_vector)
	im.surface_end()
