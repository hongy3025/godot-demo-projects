@tool
## 材质球体生成器 —— 在编辑器中生成粗糙度和金属度矩阵排列的球体。
##
## 继承自 [Node3D]，在 _ready 时生成 11×11 个球体，
## 覆盖粗糙度 0.0~1.0 和金属度 0.0~1.0 的完整范围，
## 用于直观对比不同材质参数的外观效果。
extends Node3D


## _ready 入口。生成粗糙度 × 金属度矩阵球体。
func _ready() -> void:
	# 创建球体网格，覆盖不同粗糙度和金属度级别。
	for roughness in range(11):
		for metallic in range(11):
			var sphere := MeshInstance3D.new()
			sphere.mesh = SphereMesh.new()
			# 将球体居中于节点原点。
			sphere.position = Vector3(roughness, 0, metallic) - Vector3(5, 0, 5)

			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.5, 0.5, 0.5)
			material.roughness = roughness * 0.1
			material.metallic = metallic * 0.1
			sphere.material_override = material

			add_child(sphere)
