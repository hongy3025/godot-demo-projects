## 金币 —— 玩家可收集的金币。
##
## 继承自 [Area3D]，玩家进入时播放收集动画并增加金币计数。
extends Area3D

## 金币是否已被收集。
var taken: bool = false


## 玩家进入金币区域回调。
##
## 参数:
##   body: 进入区域的节点
##
## 如果碰撞体是 Player 且金币未被收集，播放收集动画并增加金币计数。
func _on_coin_body_enter(body: Node) -> void:
	if not taken and body is Player:
		$Animation.play(&"take")
		taken = true
		# 已验证碰撞体是 Player，其有 `coins` 属性，可以安全增加。
		body.coins += 1
