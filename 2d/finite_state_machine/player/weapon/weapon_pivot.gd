## 武器枢轴节点 —— 根据玩家朝向自动旋转武器位置。
## 继承自 Marker2D，当玩家朝向改变时更新旋转和 Z 轴排序。
extends Marker2D

## 初始 Z 轴索引值。
var z_index_start := 0

func _ready() -> void:
	owner.direction_changed.connect(_on_Parent_direction_changed)
	z_index_start = z_index


## 玩家朝向变化时的回调。
## 根据朝向旋转武器，朝上时降低 Z 索引使武器显示在角色后方。
func _on_Parent_direction_changed(direction: Vector2) -> void:
	rotation = direction.angle()
	match direction:
		Vector2.UP:
			z_index = z_index_start - 1
		_:
			z_index = z_index_start
