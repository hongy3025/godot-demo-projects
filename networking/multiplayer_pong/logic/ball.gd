## 乒乓球逻辑 —— 处理球的运动、碰撞反弹和出界判定。
##
## 继承自 [Area2D]，作为乒乓球节点。
## 采用"各自判定己方边界"的策略：每个玩家只判定球是否在自己一侧出界，
## 这样即使有延迟也能保证游戏可玩性。
extends Area2D

## 球的默认移动速度（像素/秒）。
const DEFAULT_SPEED = 100.0

## 球的当前运动方向向量。
var direction := Vector2.LEFT
## 球是否已停止运动。
var stopped: bool = false
## 当前速度，随时间递增。
var _speed := DEFAULT_SPEED

## 屏幕尺寸，用于边界检测。
@onready var _screen_size := get_viewport_rect().size


## _process 每帧处理：移动球、检测边界反弹、判定出界。
##
## 球会持续加速（_speed 每帧增加 delta），增加游戏难度。
## 出界判定策略：
##   - 网络权限方（左侧玩家）判定球是否从左侧出界
##   - 非权限方（右侧玩家）判定球是否从右侧出界
func _process(delta: float) -> void:
	_speed += delta
	# 球在双方屏幕上都会正常移动，即使两者之间存在轻微不同步，
	# 每个玩家看到的运动也是平滑的，不会出现卡顿。
	if not stopped:
		translate(_speed * delta * direction)

	# 检测屏幕上下边界，使球反弹。
	var ball_pos := position
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > _screen_size.y and direction.y > 0):
		direction.y = -direction.y

	if is_multiplayer_authority():
		# 只有权限方（左侧玩家）判定球是否从左侧出界。
		# 这使得即使延迟高、球速快，游戏仍然可玩。
		# 否则球可能在对方屏幕上已出界，但本方屏幕上还没出界。
		if ball_pos.x < 0:
			get_parent().update_score.rpc(false)
			_reset_ball.rpc(false)
	else:
		# 只有非权限方（右侧玩家）判定球是否从右侧出界。
		if ball_pos.x > _screen_size.x:
			get_parent().update_score.rpc(true)
			_reset_ball.rpc(true)


## 球反弹处理。任何对等端可调用，在所有对等端本地执行。
## 参数 left: 是否从左侧球拍反弹；random: 随机值用于决定反弹角度。
@rpc("any_peer", "call_local")
func bounce(left: bool, random: float) -> void:
	if left:
		direction.x = abs(direction.x)
	else:
		direction.x = -abs(direction.x)

	_speed *= 1.1
	direction.y = random * 2.0 - 1
	direction = direction.normalized()


## 停止球的运动。任何对等端可调用，在所有对等端本地执行。
@rpc("any_peer", "call_local")
func stop() -> void:
	stopped = true


## 重置球到屏幕中央。任何对等端可调用，在所有对等端本地执行。
## 参数 for_left: true 表示球朝左侧（左侧玩家得分），false 表示朝右侧。
@rpc("any_peer", "call_local")
func _reset_ball(for_left: float) -> void:
	position = _screen_size / 2
	if for_left:
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT
	_speed = DEFAULT_SPEED
