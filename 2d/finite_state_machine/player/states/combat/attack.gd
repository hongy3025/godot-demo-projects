## 攻击状态 —— 玩家攻击时的状态。
## 继承自 player_state.gd，播放待机动画并等待剑的攻击完成信号。
extends "res://player/player_state.gd"

## 进入攻击状态：播放待机动画（实际攻击动画由剑节点控制）。
func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.idle)


## 剑攻击完成回调：回到上一个状态。
func _on_Sword_attack_finished() -> void:
	finished.emit(PLAYER_STATE.previous)
