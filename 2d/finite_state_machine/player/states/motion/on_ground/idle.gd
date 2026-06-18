## 待机状态 —— 玩家站立不动。
## 继承自 on_ground.gd，检测到输入方向时切换到移动状态。
extends "on_ground.gd"

## 进入待机状态：播放待机动画。
func enter() -> void:
	owner.get_node(^"AnimationPlayer").play(PLAYER_STATE.idle)


## 处理输入：委托给父类。
func handle_input(input_event: InputEvent) -> void:
	return super.handle_input(input_event)


## 每帧更新：检测到输入方向时切换到移动状态。
func update(_delta: float) -> void:
	var input_direction: Vector2 = get_input_direction()
	if input_direction:
		finished.emit(PLAYER_STATE.move)
