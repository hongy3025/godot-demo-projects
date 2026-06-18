## 炸弹逻辑 —— 处理爆炸检测、射线遮挡判定和生命周期。
##
## 继承自 [Area2D]，作为游戏中的炸弹节点。
## 爆炸时通过 PhysicsRayQueryParameters2D 检测炸弹与目标之间是否有墙壁遮挡。
extends Area2D

## 炸弹爆炸范围内的物体列表。
var in_area: Array = []
## 放置该炸弹的玩家 ID。
var from_player: int


## 炸弹爆炸处理。由动画播放器在动画关键帧调用。
##
## 仅网络权限方执行爆炸逻辑。
## 对范围内的每个物体进行射线检测，如果炸弹与目标之间没有 TileMap 遮挡，
## 则调用目标的 exploded 方法。
func explode() -> void:
	if not is_multiplayer_authority():
		return

	for p: Object in in_area:
		if p.has_method(&"exploded"):
			# 检测炸弹和目标之间是否有墙壁遮挡。
			var world_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(position, p.position)
			query.hit_from_inside = true
			var result: Dictionary  = world_state.intersect_ray(query)
			if result.collider is not TileMap:
				# exploded 只能由权限方调用，但会在本地也执行。
				p.exploded.rpc(from_player)


## 炸弹爆炸动画完成后调用。仅权限方执行删除。
func done() -> void:
	if is_multiplayer_authority():
		queue_free()


## 物体进入炸弹爆炸范围。
## 参数 body: 进入范围的 Node2D。
func _on_bomb_body_enter(body: Node2D) -> void:
	if not body in in_area:
		in_area.append(body)


## 物体离开炸弹爆炸范围。
## 参数 body: 离开范围的 Node2D。
func _on_bomb_body_exit(body: Node2D) -> void:
	in_area.erase(body)
