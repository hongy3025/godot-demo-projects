## 2D 轴向标记 —— 在 2D 空间中显示从原点到当前位置的方向线。
##
## 继承自 [Node2D]，自动绘制一条从父节点原点到自身位置的线段。
@tool
@icon("res://marker/AxisMarker2D.svg")
class_name AxisMarker2D
extends Node2D


## _process 入口，每帧更新线段终点和变换。
func _process(_delta: float) -> void:
	var line: Line2D = get_child(0).get_child(0)
	var marker_parent: Node = get_parent()

	line.points[1] = transform.origin
	if marker_parent as Node2D != null:
		line.transform = marker_parent.global_transform
