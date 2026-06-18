## 子弹节点 —— 沿指定方向高速移动的投射物。
## 继承自 CharacterBody2D，超出屏幕或碰撞时自动销毁。
extends CharacterBody2D

## 子弹飞行方向。
var direction := Vector2()
## 子弹飞行速度（像素/秒）。
@export var speed := 1000.0

## 场景根节点引用，用于检测屏幕边界。
@onready var root := get_tree().root

func _ready() -> void:
	# 设置为顶层，使子弹不受父节点变换影响
	set_as_top_level(true)


## 物理帧更新：移动子弹，超出屏幕或碰撞时销毁。
func _physics_process(delta: float) -> void:
	# 超出可见区域时销毁
	if not root.get_visible_rect().has_point(position):
		queue_free()

	# 沿方向移动
	var motion := direction * speed * delta
	var collision_info := move_and_collide(motion)
	if collision_info:
		queue_free()


## 自定义绘制：绘制子弹的圆形外观。
func _draw() -> void:
	draw_circle(Vector2(), $CollisionShape2D.shape.radius, Color.WHITE)
