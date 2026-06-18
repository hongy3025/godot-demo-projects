## 踉跄状态 —— 玩家受到伤害时的硬直动画。
## 继承自 player_state.gd，踉跄动画结束后回到上一个状态。
## 动画仅影响 Body Sprite2D 的 modulate 属性，因此如果有两个 AnimationPlayer，
## 可以与其他动画叠加。
extends "res://player/player_state.gd"

## 进入踉跄状态：播放踉跄动画。
func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.stagger)


## 动画播放完成：回到上一个状态。
func _on_animation_finished(anim_name: String) -> void:
	assert(anim_name == PLAYER_STATE.stagger)
	finished.emit(PLAYER_STATE.previous)
