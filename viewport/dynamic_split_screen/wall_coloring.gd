## 墙壁着色器 —— 为所有属于 "walls" 组的物体设置随机颜色。
##
## 标记为 @tool，可在编辑器中运行。
## 继承自 [Node3D]，挂载到场景中的 "Walls" 节点上使用。
## 在 _ready 时遍历所有属于 "walls" 组的节点，为每个节点创建一个随机颜色的材质并覆盖。
@tool
extends Node3D


## 初始化：遍历 "walls" 组中的所有节点，为每个节点生成随机颜色的材质。
func _ready() -> void:
	var walls := get_tree().get_nodes_in_group(&"walls")
	for wall in walls:
		var material := StandardMaterial3D.new()
		# 生成随机 RGB 颜色
		material.albedo_color = Color(randf(), randf(), randf())

		# 将随机颜色材质设置为节点的材质覆盖
		wall.material_override = material
