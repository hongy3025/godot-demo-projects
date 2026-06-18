## 墙壁节点 —— 检测球体出界并重置。
extends Area2D

func _on_wall_area_entered(area: Area2D) -> void:
	if area.name == "Ball":
		area.reset()
