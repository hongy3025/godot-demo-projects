## 地面状态基类 —— 玩家在地面上的通用状态。
## 继承自 motion.gd，处理跳跃输入和地面移动速度。
extends "../motion.gd"

## 当前移动速度。
var speed := 0.0
## 当前速度向量。
var velocity := Vector2()

## 处理输入：检测跳跃输入，否则委托给父类。
func handle_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"jump"):
		finished.emit(PLAYER_STATE.jump)

	return super.handle_input(input_event)
