## 动态瓦片地图层 —— 运行时修改瓦片属性的示例。
## 继承自 TileMapLayer，当玩家进入秘密区域时动态改变图层透明度并移除碰撞。
extends TileMapLayer

## 玩家是否在秘密区域内。
var player_in_secret: bool = false
## 当前图层透明度。
var layer_alpha := 1.0


func _ready() -> void:
	set_process(false)


## 每帧平滑过渡图层透明度。
func _process(delta: float) -> void:
	if player_in_secret:
		if layer_alpha > 0.3:
			layer_alpha = move_toward(layer_alpha, 0.3, delta)
			self_modulate = Color(1, 1, 1, layer_alpha)
		else:
			set_process(false)
	else:
		if layer_alpha < 1.0:
			layer_alpha = move_toward(layer_alpha, 1.0, delta)
			self_modulate = Color(1, 1, 1, layer_alpha)
		else:
			set_process(false)


## 启用运行时瓦片数据更新。
func _use_tile_data_runtime_update(_coords: Vector2i) -> bool:
	return true


## 运行时更新瓦片数据：移除秘密区域的碰撞。
func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_collision_polygons_count(0, 0)


## 玩家进入秘密区域检测器。
func _on_secret_detector_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	player_in_secret = true
	set_process(true)


## 玩家离开秘密区域检测器。
func _on_secret_detector_body_exited(body: Node2D) -> void:
	if body is not CharacterBody2D:
		return

	player_in_secret = false
	set_process(true)
