## 玩家角色 —— 演示序列化/反序列化的目标对象。
## 继承自 [CharacterBody2D]，使用 Godot 的物理移动系统。
## 拥有生命值系统，生命值归零时重新加载当前场景。
## 通过键盘方向键控制移动，按方向键时旋转精灵朝向对应方向。
class_name Player
extends CharacterBody2D

## 移动速度，单位：像素/秒。
const MOVEMENT_SPEED = 240.0

## 玩家生命值。通过自定义 setter 在生命值变化时更新进度条显示。
## 当生命值 <= 0 时，重新加载当前场景（玩家死亡）。
var health := 100.0:
	get:
		return health
	set(value):
		health = value
		progress_bar.value = value
		if health <= 0.0:
			# 玩家死亡
			get_tree().reload_current_scene()
## 移动向量，存储当前帧的输入方向。
var motion := Vector2()

## 生命值进度条的引用（@onready 确保在 _ready 后节点可用时初始化）。
@onready var progress_bar := $ProgressBar as ProgressBar
## 玩家精灵节点的引用。
@onready var sprite := $Sprite2D as Sprite2D


## 每帧处理玩家输入和移动。
## 参数:
##   _delta: 上一帧到这一帧的时间差（秒），此处未使用
## 核心逻辑: 获取方向输入向量，归一化后乘以移动速度，调用 move_and_slide() 进行物理移动。
func _process(_delta: float) -> void:
	velocity = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	# 如果输入向量长度大于 1，归一化以防止对角线移动速度过快
	if velocity.length_squared() > 1.0:
		velocity = velocity.normalized()
	velocity *= MOVEMENT_SPEED
	move_and_slide()


## 处理输入事件，根据按下的方向键旋转精灵朝向。
## 参数:
##   input_event: 输入事件对象
## 核心逻辑: 检测方向键按下，设置精灵的 rotation 属性为对应角度。
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"move_left"):
		sprite.rotation = PI / 2
	elif input_event.is_action_pressed(&"move_right"):
		sprite.rotation = -PI / 2
	elif input_event.is_action_pressed(&"move_up"):
		sprite.rotation = PI
	elif input_event.is_action_pressed(&"move_down"):
		sprite.rotation = 0.0
