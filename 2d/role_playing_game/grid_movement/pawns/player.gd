## 玩家棋子 —— 由键盘控制移动的 Walker。
## 每帧检测方向输入，向 Grid 请求移动。
extends Walker

## 每帧处理玩家输入并请求移动。
func _process(_delta: float) -> void:
	var input_direction := get_input_direction()
	# 只允许整数方向（一次移动一个格子）
	input_direction = input_direction.round()

	if input_direction.is_zero_approx():
		return

	# 更新朝向
	update_look_direction(input_direction)

	# 向 Grid 请求移动，如果目标格子可通行则执行移动动画
	var target_position: Vector2 = grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	elif active:
		# 遇到障碍物播放碰撞动画
		bump()


## 获取玩家的输入方向向量。
## 返回: Vector2，四个方向之一的单位向量。
func get_input_direction() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
