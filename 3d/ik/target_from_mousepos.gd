## 鼠标位置 IK 目标控制器 —— 将鼠标位置映射为 IK 目标位置。
##
## 继承自 [Camera3D]，将鼠标在屏幕上的位置投影到 3D 空间，
## 作为 IK（反向动力学）的目标点，实现鼠标控制角色手臂/武器指向。
extends Camera3D

## 鼠标到世界坐标的投影距离。
@export var MOVEMENT_SPEED: float = 12
## 是否翻转坐标轴。
@export var flip_axis: bool = false

## IK 目标节点的子节点容器。
@onready var targets = $Targets


## _process 入口。每帧将鼠标位置投影到 3D 空间并更新目标位置。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 将鼠标位置从屏幕空间投影到局部射线方向
## 2. 乘以距离得到世界坐标
## 3. 根据 flip_axis 决定是否翻转坐标轴
func _process(_delta):
	var mouse_to_world = (
			project_local_ray_normal(get_viewport().get_mouse_position()) * MOVEMENT_SPEED
		)

	if flip_axis:
		mouse_to_world = -mouse_to_world
	else:
		mouse_to_world.z *= -1

	targets.transform.origin = mouse_to_world
