## 运动状态基类 —— 处理方向和动画的通用方法集合。
## 继承自 player_state.gd，提供输入方向和朝向更新的工具方法。
extends "res://player/player_state.gd"

## 处理输入：检测模拟伤害输入，切换到踉跄状态。
func handle_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"simulate_damage"):
		finished.emit(PLAYER_STATE.stagger)


## 获取玩家输入的方向向量。
## 返回: Vector2，标准化后的方向。
func get_input_direction() -> Vector2:
	return Vector2(
			Input.get_axis(&"move_left", &"move_right"),
			Input.get_axis(&"move_up", &"move_down")
		)


## 更新玩家朝向。
## 参数 direction: 新的朝向方向。
func update_look_direction(direction: Vector2) -> void:
	if direction and owner.look_direction != direction:
		owner.look_direction = direction
