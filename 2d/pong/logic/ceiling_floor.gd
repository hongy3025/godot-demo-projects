## 天花板/地板节点 —— 碰撞球体时反弹。
extends Area2D

## 反弹方向（1 为向下，-1 为向上）。
@export var _bounce_direction := 1

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Ball":
		area.direction = (area.direction + Vector2(0, _bounce_direction)).normalized()
