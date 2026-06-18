## 玩家节点 —— 躲避怪物游戏的主角。
## 继承自 Area2D，通过鼠标/键盘控制移动，被怪物碰撞时发射 hit 信号。
extends Area2D

## 被怪物碰撞时发射的信号。
signal hit

## 玩家移动速度（像素/秒）。
@export var speed = 400
## 游戏窗口大小，用于限制玩家位置。
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	hide()


## 每帧处理玩家输入和移动。
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	# 有输入时播放动画，否则停止
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# 更新位置并限制在屏幕内
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# 根据移动方向选择动画和翻转
	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0


## 在指定位置生成玩家。
func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false


## 碰撞体进入回调：玩家被怪物击中。
func _on_body_entered(_body):
	hide()
	hit.emit()
	# 必须延迟禁用碰撞，因为不能在物理回调中修改物理属性
	$CollisionShape2D.set_deferred(&"disabled", true)
