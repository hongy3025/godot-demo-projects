## 分屏输入玩家 —— 接收路由后的输入事件并控制 2D 角色移动。
##
## 继承自 [CharacterBody2D]，通过 class_name 注册为可全局使用的类型。
## 使用 _unhandled_input 接收经过 InputRoutingViewportContainer 过滤后的输入事件，
## 更新移动方向向量，在 _physics_process 中执行实际移动。
class_name Player

# 继承自 CharacterBody2D，这是 Godot 4 中专用于 2D 角色移动的物理节点。
# 它内置了移动和碰撞处理功能，适合作为玩家或 NPC 的基类。
extends CharacterBody2D

## 移动速度倍率，用于将方向向量转换为实际像素位移。
const factor: float = 200.0

## 当前移动方向向量，由输入事件更新。
var _movement: Vector2 = Vector2(0, 0)


## 处理到达此子视口的输入事件，更新移动方向。
## 参数:
##   input_event: 输入事件对象
##
## 支持 ux_up/ux_down/ux_left/ux_right 四个动作。
## 按键按下时增加对应方向的值，按键释放时减少对应方向的值。
## 每次处理后调用 set_input_as_handled() 标记事件已处理，防止重复响应。
## 移动速度因子，类型为 float，数值为 200.0。
## 最终的像素移动速度等于 _movement 向量乘以该因子，单位是 像素/秒。
const factor: float = 200.0

## 当前移动速率/方向向量，类型为 Vector2，初始值为 (0, 0)。
## 该向量的每个分量是整数步进（-1、0 或 1），表示玩家在各轴上的移动意图。
## 正值表示向下/向右，负值表示向上/向左。
var _movement: Vector2 = Vector2(0, 0)


## 根据到达该 SubViewport 的输入更新移动变量。
## _unhandled_input 是 Node 的内置虚函数，当输入事件未被 GUI 或其他节点消费时触发。
## 由于 input_router 的过滤，只有分配给该分屏的按键/手柄事件才会到达此处。
func _unhandled_input(input_event: InputEvent) -> void:
	# 判断条件：按下了 "ux_up"（上移动作），或者释放了 "ux_down"（下移动作）。
	# 逻辑解释：这两个动作都会导致垂直方向上的"向上净效果"增加。
	# 例如：按下上键开始向上走；按下下键时 y+1，释放下键时取消这个 +1，相当于回到原地或更偏上。
	if input_event.is_action_pressed(&"ux_up") or input_event.is_action_released(&"ux_down"):
		# 将 _movement 的 y 分量减 1。y 减小意味着向上移动（Godot 2D 坐标系中 y 轴向下为正）。
		_movement.y -= 1
		# 调用 set_input_as_handled() 标记该输入事件已被处理，阻止其继续向上层节点传播。
		get_viewport().set_input_as_handled()
	# 判断条件：按下了 "ux_down"，或者释放了 "ux_up"。
	# 这会导致垂直方向上的"向下净效果"增加。
	elif input_event.is_action_pressed(&"ux_down") or input_event.is_action_released(&"ux_up"):
		# 将 _movement 的 y 分量加 1，表示向下移动。
		_movement.y += 1
		# 标记输入已处理。
		get_viewport().set_input_as_handled()
	# 判断条件：按下了 "ux_left"，或者释放了 "ux_right"。
	# 导致水平方向上的"向左净效果"增加。
	elif input_event.is_action_pressed(&"ux_left") or input_event.is_action_released(&"ux_right"):
		# 将 _movement 的 x 分量减 1。x 减小意味着向左移动。
		_movement.x -= 1
		# 标记输入已处理。
		get_viewport().set_input_as_handled()
	# 判断条件：按下了 "ux_right"，或者释放了 "ux_left"。
	# 导致水平方向上的"向右净效果"增加。
	elif input_event.is_action_pressed(&"ux_right") or input_event.is_action_released(&"ux_left"):
		# 将 _movement 的 x 分量加 1，表示向右移动。
		_movement.x += 1
		# 标记输入已处理。
		get_viewport().set_input_as_handled()
	# 注意：该输入方案采用了一种"相反按键释放时抵消"的设计。
	# 例如同时按下上和下，_movement.y 先 -1 再 +1，净效果为 0，角色停止垂直移动。


## 物理帧更新：根据移动方向向量移动角色。
## 参数:
##   delta: 帧时间差（秒）
##
## 使用 move_and_collide 进行物理移动，方向向量乘以速度倍率和时间差。
## 根据 movement 变量的内容移动节点。
## _physics_process 是 Node 的内置虚函数，以固定帧率（与物理同步）被调用。
## delta 参数为上一次物理帧到本次所经过的时间（秒），用于保证运动与帧率无关。
func _physics_process(delta: float) -> void:
	# 调用 CharacterBody2D 的 move_and_collide 方法进行移动。
	# 参数计算：_movement（方向向量，分量通常为 -1/0/1） × factor（速度因子 200） × delta（时间增量）。
	# 结果是一个表示本帧期望位移的 Vector2，单位为像素。
	# 如果移动路径上有 CollisionObject2D，该方法会处理碰撞并在碰到时停止滑动（不同于 move_and_slide）。
	move_and_collide(_movement * factor * delta)
