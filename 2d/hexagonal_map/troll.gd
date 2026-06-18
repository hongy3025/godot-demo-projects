## 巨魔角色 —— 六边形地图上的移动角色。
## 继承自 CharacterBody2D，使用摩擦力实现平滑移动，Y 轴按六边形比例调整。
extends CharacterBody2D

## 移动速度。
const MOTION_SPEED = 30
## 摩擦力系数，每帧乘以该值减速。
const FRICTION_FACTOR = 0.89
## tan(30°) 常数，用于六边形地图的 Y 轴调整。
const TAN30DEG = tan(deg_to_rad(30))

func _physics_process(_delta: float) -> void:
	var motion := Vector2()
	motion.x = Input.get_axis(&"move_left", &"move_right")
	motion.y = Input.get_axis(&"move_up", &"move_down")
	# 使对角线移动适配六边形瓦片
	motion.y *= TAN30DEG
	velocity += motion.normalized() * MOTION_SPEED
	# 应用摩擦力
	velocity *= FRICTION_FACTOR
	move_and_slide()
