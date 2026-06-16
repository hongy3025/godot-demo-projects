extends Node2D
# 继承自 Node2D 类，使该脚本附加的节点具有 2D 空间中的变换能力（位置、旋转、缩放）。

const PAD_SPEED = 150
# 定义常量 PAD_SPEED（球拍移动速度），数值为 150 像素/秒。
const INITIAL_BALL_SPEED = 80.0
# 定义常量 INITIAL_BALL_SPEED（球的初始速度），数值为 80.0 像素/秒，使用浮点数类型。

var ball_speed := INITIAL_BALL_SPEED
# 声明变量 ball_speed（当前球速），并使用类型推断（:=）初始化为 INITIAL_BALL_SPEED。
# 这个值会在游戏中随着球拍碰撞而增加，因此用变量而非常量。
var screen_size := Vector2(640, 400)
# 声明变量 screen_size（屏幕尺寸），初始值为 Vector2(640, 400)。
# 用于判断球的边界碰撞，后续会在 _ready 中更新为实际视口大小。

# Default ball direction.
# 英文注释：球的默认运动方向。
var direction := Vector2.LEFT
# 声明变量 direction（球的运动方向向量），初始化为 Vector2.LEFT，即 (-1, 0)，表示向左运动。
var pad_size := Vector2(8, 32)
# 声明变量 pad_size（球拍尺寸），初始值为 Vector2(8, 32)。
# 后续会在 _ready 中根据实际精灵纹理尺寸更新。

@onready var ball: Sprite2D = $Ball
# @onready 表示在节点完全进入场景树后执行此行赋值。
# 获取名为 "Ball" 的子节点（Sprite2D 类型，即球精灵），并赋值给 ball 变量。
@onready var left_paddle: Sprite2D = $LeftPaddle
# 获取名为 "LeftPaddle" 的子节点（左球拍精灵），并赋值给 left_paddle 变量。
@onready var right_paddle: Sprite2D = $RightPaddle
# 获取名为 "RightPaddle" 的子节点（右球拍精灵），并赋值给 right_paddle 变量。

func _ready() -> void:
	# _ready 是 Godot 的内置虚函数，当节点及其子节点都进入场景树后自动调用一次。
	# -> void 表示该函数不返回任何值。
	screen_size = get_viewport_rect().size  # Get actual size.
	# 通过 get_viewport_rect().size 获取游戏窗口的实际尺寸，覆盖之前的默认值。
	# 这样无论窗口实际大小如何，碰撞检测都能正确适配。
	pad_size = left_paddle.get_texture().get_size()
	# 获取左球拍精灵使用的纹理（图片）的实际像素尺寸，并赋值给 pad_size。
	# 这样碰撞矩形的尺寸会与实际显示的球拍大小一致。


func _process(delta: float) -> void:
	# _process 是 Godot 的内置虚函数，每帧都会被调用一次。
	# delta 参数表示上一帧到当前帧所经过的时间（秒），用于保证运动速度不受帧率影响。
	# Get ball position and pad rectangles.
	# 英文注释：获取球的位置以及左右球拍的碰撞矩形。
	var ball_pos := ball.get_position()
	# 获取球精灵当前的 2D 坐标位置，并赋值给 ball_pos 变量。
	var left_rect := Rect2(left_paddle.get_position() - pad_size * 0.5, pad_size)
	# 构造左球拍的碰撞矩形（Rect2）。
	# 矩形起点为球拍中心位置减去 pad_size 的一半（将中心坐标转换为左上角坐标），大小为 pad_size。
	var right_rect := Rect2(right_paddle.get_position() - pad_size * 0.5, pad_size)
	# 构造右球拍的碰撞矩形，逻辑与左球拍相同。

	# Integrate new ball position.
	# 英文注释：积分计算球的新位置（基于速度和 delta 时间）。
	ball_pos += direction * ball_speed * delta
	# 更新球的位置：方向向量 × 当前速度 × 时间增量。
	# 这样球每帧移动的距离与帧率无关，保证不同设备上速度一致。

	# Flip when touching roof or floor.
	# 英文注释：当球碰到顶部或底部边界时，翻转垂直方向。
	if (ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0):
		# 判断条件：
		# 1) 球的 y 坐标小于 0（超出顶部）且当前正在向上运动（direction.y < 0），或者
		# 2) 球的 y 坐标大于屏幕高度（超出底部）且当前正在向下运动（direction.y > 0）。
		direction.y = -direction.y
		# 将方向向量的 y 分量取反，使球在垂直方向上反弹。

	# Flip, change direction, and increase speed when touching pads.
	# 英文注释：当球碰到球拍时，水平翻转方向、增加速度，并随机化垂直方向。
	if (left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0):
		# 判断条件：
		# 1) 球的位置位于左球拍矩形内，且球正在向左运动（direction.x < 0），或者
		# 2) 球的位置位于右球拍矩形内，且球正在向右运动（direction.x > 0）。
		# 这样确保球只会从正面碰撞球拍时反弹，避免卡在球拍内部反复反弹。
		direction.x = -direction.x
		# 将方向向量的 x 分量取反，使球在水平方向上反弹（向左变向右，向右变向左）。
		ball_speed *= 1.1
		# 将球的速度乘以 1.1，即每次击中球拍后速度增加 10%，使游戏节奏逐渐加快。
		direction.y = randf() * 2.0 - 1
		# 随机生成一个新的 y 方向分量：randf() 返回 0~1 之间的随机浮点数，乘以 2 再减 1，得到 -1~1 之间的随机值。
		# 这样每次击中球拍后，球的反弹角度都会变得不确定，增加游戏趣味性。
		direction = direction.normalized()
		# 将方向向量归一化（长度变为 1），确保球的速度只由 ball_speed 控制，方向不影响速度大小。

	# Check gameover.
	# 英文注释：检查是否出界（游戏结束/失分条件）。
	if ball_pos.x < 0 or ball_pos.x > screen_size.x:
		# 如果球的 x 坐标小于 0（超出左边界）或大于屏幕宽度（超出右边界）。
		ball_pos = screen_size * 0.5
		# 将球的位置重置到屏幕正中心（屏幕尺寸 × 0.5）。
		ball_speed = INITIAL_BALL_SPEED
		# 将球速重置为初始速度。
		direction = Vector2(-1, 0)
		# 将球的运动方向重置为向左（-1, 0）。

	ball.set_position(ball_pos)
	# 将更新后的位置应用到球精灵上，使其在屏幕上实际移动。

	# Move left pad.
	# 英文注释：处理左球拍的移动输入。
	var left_pos := left_paddle.get_position()
	# 获取左球拍当前的 2D 坐标位置。

	if left_pos.y > 0 and Input.is_action_pressed(&"left_move_up"):
		# 判断条件：左球拍未超出屏幕顶部（y > 0），且玩家按下了 "left_move_up" 输入动作。
		# &"string" 是 Godot 4 中 StringName 的简写语法，用于输入映射名称，性能更优。
		left_pos.y += -PAD_SPEED * delta
		# 将球拍的 y 坐标向上移动：负号表示向上，乘以 delta 保证帧率无关。
	if left_pos.y < screen_size.y and Input.is_action_pressed(&"left_move_down"):
		# 判断条件：左球拍未超出屏幕底部（y < screen_size.y），且玩家按下了 "left_move_down" 输入动作。
		left_pos.y += PAD_SPEED * delta
		# 将球拍的 y 坐标向下移动。

	left_paddle.set_position(left_pos)
	# 将更新后的位置应用到左球拍精灵上。

	# Move right pad.
	# 英文注释：处理右球拍的移动输入，逻辑与左球拍完全对称。
	var right_pos := right_paddle.get_position()
	# 获取右球拍当前的 2D 坐标位置。
	if right_pos.y > 0 and Input.is_action_pressed(&"right_move_up"):
		# 判断条件：右球拍未超出屏幕顶部，且按下了 "right_move_up" 动作。
		right_pos.y += -PAD_SPEED * delta
		# 向上移动右球拍。
	if right_pos.y < screen_size.y and Input.is_action_pressed(&"right_move_down"):
		# 判断条件：右球拍未超出屏幕底部，且按下了 "right_move_down" 动作。
		right_pos.y += PAD_SPEED * delta
		# 向下移动右球拍。

	right_paddle.set_position(right_pos)
	# 将更新后的位置应用到右球拍精灵上。
