## 昼夜循环控制器 —— 使 DirectionalLight3D 沿 X 轴缓慢旋转模拟昼夜交替。
##
## 继承自 [DirectionalLight3D]，每帧绕局部 X 轴旋转以模拟太阳的昼夜运动。
extends DirectionalLight3D


## _process 入口。每帧绕局部 X 轴旋转。
##
## 参数:
##   delta: 帧时间间隔
##
## 旋转速度固定为 0.025 弧度/秒。
func _process(delta: float) -> void:
	rotate_object_local(Vector3.RIGHT, 0.025 * delta)
