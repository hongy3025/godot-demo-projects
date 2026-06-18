## Sprite3D 旋转控制器 —— 使 Sprite3D 绕 Y 轴持续旋转。
##
## 继承自 [Sprite3D]，以指定速度绕 Y 轴旋转。
extends Sprite3D

## 旋转速度（度/秒）。
@export var speed_deg: float = 90.0


## _process 入口。每帧绕 Y 轴旋转。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(speed_deg * delta))
