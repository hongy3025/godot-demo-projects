## 简单子弹 —— 发射后自动销毁的刚体子弹。
##
## 继承自 [RigidBody3D]，发射后经过 DESPAWN_TIME 秒自动销毁。
extends RigidBody3D

## 子弹存活时间（秒）。
const DESPAWN_TIME = 5

## 存活计时器。
var timer = 0


## _ready 入口。启用物理处理。
func _ready():
	set_physics_process(true);


## _physics_process 入口。每物理帧更新计时器，超时后销毁。
##
## 参数:
##   delta: 物理帧时间间隔
func _physics_process(delta):
	timer += delta
	if timer > DESPAWN_TIME:
		queue_free()
		timer = 0
