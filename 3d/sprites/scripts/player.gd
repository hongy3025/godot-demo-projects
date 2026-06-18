## 2D 风格 3D 玩家控制器 —— 在 3D 空间中使用 AnimatedSprite3D 实现 2D 风格移动。
##
## 继承自 [Node3D]，使用 AnimatedSprite3D 播放方向动画（上下左右行走）。
extends Node3D

## AnimatedSprite3D 节点引用。
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
## 移动速度。
@export var move_speed: float = 5.0

## 当前速度向量。
var velocity: Vector3 = Vector3.ZERO


## _process 入口。每帧处理输入、移动和动画切换。
##
## 参数:
##   delta: 帧时间间隔
##
## 核心逻辑：
## 1. 读取 WASD 输入
## 2. 归一化输入向量
## 3. 将 2D 输入转换为 3D 移动
## 4. 根据移动方向播放对应的行走动画
func _process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO

	input_vector.x = Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left")
	input_vector.y = Input.get_action_strength(&"move_back") - Input.get_action_strength(&"move_forward")

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		# 在 3D 空间中更新玩家位置。
		velocity = Vector3(input_vector.x, 0, input_vector.y) * move_speed
		translate(velocity * delta)

		# 播放对应的动画。
		if abs(input_vector.x) > abs(input_vector.y):
			sprite.play(&"walk_right" if input_vector.x > 0 else &"walk_left")
		else:
			sprite.play(&"walk_down" if input_vector.y > 0 else &"walk_up")
	else:
		sprite.stop()
