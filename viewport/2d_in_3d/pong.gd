## 乒乓球游戏逻辑 —— 一个简单的双人乒乓球（Pong）游戏实现。
##
## 继承自 [Node2D]，作为 2D 游戏的核心逻辑脚本。
## 包含球和两个球拍的移动、碰撞检测、得分重置等完整游戏逻辑。
## 此游戏渲染在 SubViewport 中，再映射到 3D 空间中的 Quad 上。
extends Node2D

## 球拍的移动速度（像素/秒）。
const PAD_SPEED = 150
## 球的初始速度。
const INITIAL_BALL_SPEED = 80.0

## 当前球的速度，每次击中球拍时加速。
var ball_speed := INITIAL_BALL_SPEED
## 屏幕尺寸，在 _ready 中根据实际视口大小初始化。
var screen_size := Vector2(640, 400)

## 球的默认移动方向。
var direction := Vector2.LEFT
## 球拍的尺寸（宽 x 高）。
var pad_size := Vector2(8, 32)

## 球的 Sprite2D 节点引用。
@onready var ball: Sprite2D = $Ball
## 左侧球拍的 Sprite2D 节点引用。
@onready var left_paddle: Sprite2D = $LeftPaddle
## 右侧球拍的 Sprite2D 节点引用。
@onready var right_paddle: Sprite2D = $RightPaddle

## 初始化：获取实际屏幕尺寸和球拍纹理尺寸。
func _ready() -> void:
	screen_size = get_viewport_rect().size
	pad_size = left_paddle.get_texture().get_size()


## 每帧更新：处理球移动、碰撞检测、球拍移动。
## 参数:
##   delta: 帧时间差（秒）
##
## 核心逻辑：
##   1. 球沿当前方向移动
##   2. 碰到上下边界时反弹 Y 方向
##   3. 碰到球拍时反弹 X 方向、加速并随机化 Y 方向
##   4. 球出界时重置到中心
##   5. 处理两个球拍的上下移动输入
func _process(delta: float) -> void:
	var ball_pos := ball.get_position()
	var left_rect := Rect2(left_paddle.get_position() - pad_size * 0.5, pad_size)
	var right_rect := Rect2(right_paddle.get_position() - pad_size * 0.5, pad_size)

	# 更新球的位置
	ball_pos += direction * ball_speed * delta

	# 碰到上下边界时反弹 Y 方向
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0):
		direction.y = -direction.y

	# 碰到球拍时反弹 X 方向、加速并随机化 Y 方向
	if (left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0):
		direction.x = -direction.x
		ball_speed *= 1.1
		direction.y = randf() * 2.0 - 1
		direction = direction.normalized()

	# 球出界时重置到屏幕中心
	if ball_pos.x < 0 or ball_pos.x > screen_size.x:
		ball_pos = screen_size * 0.5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(-1, 0)

	ball.set_position(ball_pos)

	# 处理左侧球拍移动（W/S 键或上/下方向键）
	var left_pos := left_paddle.get_position()

	if left_pos.y > 0 and Input.is_action_pressed(&"left_move_up"):
		left_pos.y += -PAD_SPEED * delta
	if left_pos.y < screen_size.y and Input.is_action_pressed(&"left_move_down"):
		left_pos.y += PAD_SPEED * delta

	left_paddle.set_position(left_pos)

	# 处理右侧球拍移动
	var right_pos := right_paddle.get_position()
	if right_pos.y > 0 and Input.is_action_pressed(&"right_move_up"):
		right_pos.y += -PAD_SPEED * delta
	if right_pos.y < screen_size.y and Input.is_action_pressed(&"right_move_down"):
		right_pos.y += PAD_SPEED * delta

	right_paddle.set_position(right_pos)
