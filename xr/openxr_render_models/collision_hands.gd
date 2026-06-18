## 碰撞手部节点 —— 为 XR 手部模型提供物理碰撞体。
## 使用类名注册为 [code]CollisionHands3D[/code]。
## 继承自 [AnimatableBody3D]，跟随父节点的变换并应用物理碰撞。
class_name CollisionHands3D
extends AnimatableBody3D


## _ready 初始化 —— 设置物理属性。
## 启用 top_level 使变换独立于父节点层级，
## 设置物理处理优先级为 -90 以确保在标准物理处理之后执行。
func _ready():
	top_level = true
	sync_to_physics = false
	process_physics_priority = -90


## _physics_process 物理帧更新 —— 跟随父节点变换。
## 参数:
##   _delta: 物理帧时间间隔（秒）
##
## 仅复制旋转，然后使用 move_and_collide 移动到父节点位置。
func _physics_process(_delta):
	var dest_transform = get_parent().global_transform

	# 仅应用旋转
	global_basis = dest_transform.basis

	# 移动到跟踪手的位置
	move_and_collide(dest_transform.origin - global_position)
