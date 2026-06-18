## 岩石节点 —— 可被炸弹摧毁的静态物体。
##
## 继承自 [CharacterBody2D]，作为游戏场景中的可摧毁障碍物。
## 当被炸弹波及时，通过 RPC 通知计分板增加分数并播放爆炸动画。
extends CharacterBody2D


## 岩石被炸毁处理。在所有对等端本地调用。
## 参数 by_who: 放置炸弹的玩家 ID。
@rpc("call_local")
func exploded(by_who: int) -> void:
	$"../../Score".increase_score(by_who)
	$"AnimationPlayer".play(&"explode")
