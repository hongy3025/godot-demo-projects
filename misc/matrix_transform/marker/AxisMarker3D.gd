## 3D 轴向标记 —— 在 3D 空间中显示从原点到当前位置的方向向量。
##
## 继承自 [Node3D]，自动计算并显示一个指向自身位置的箭头。
## 当位于原点时隐藏箭头。
@tool
@icon("res://marker/AxisMarker3D.svg")
class_name AxisMarker3D
extends Node3D


## _process 入口，每帧更新箭头方向和长度。
func _process(_delta: float) -> void:
	var holder: Node3D = get_child(0).get_child(0)
	var cube: Node3D = holder.get_child(0)
	# 如果 AxisMarker 在原点，隐藏方向向量
	if position == Vector3():
		holder.transform = Transform3D()
		cube.transform = Transform3D().scaled(Vector3.ONE * 0.0001)
		return

	holder.transform = Transform3D(Basis(), position / 2)
	holder.transform = holder.transform.looking_at(position, Vector3.UP)
	holder.transform = get_parent().global_transform * holder.transform
	cube.transform = Transform3D(Basis().scaled(Vector3(0.1, 0.1, position.length())))
