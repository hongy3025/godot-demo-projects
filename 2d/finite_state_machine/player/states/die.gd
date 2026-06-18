## 死亡状态 —— 玩家死亡时的处理逻辑。
## 继承自 player_state.gd，播放死亡动画后切换到死亡完成状态。
extends "res://player/player_state.gd"

## 进入死亡状态：标记玩家死亡并播放死亡动画。
func enter() -> void:
	owner.set_dead(true)
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.die)


## 死亡动画播放完成：切换到死亡完成状态。
func _on_animation_finished(_anim_name: String) -> void:
	finished.emit(PLAYER_STATE.dead)
