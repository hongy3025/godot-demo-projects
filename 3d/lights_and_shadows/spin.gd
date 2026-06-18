## 旋转动画组件 —— 使节点绕 Y 轴旋转并在 XZ 平面上做圆周运动。
##
## 继承自 [Node3D]，演示光源或物体的圆周运动与自转。
extends Node3D

## 累积增量，用于计算圆周运动的位置和旋转角度。
var increment := 0.0

## _process 入口。每帧更新位置和旋转。
##
## 参数:
##   delta: 帧时间间隔
##
## 核心逻辑：
## 1. 在 XZ 平面上做圆周运动（sin/cos）
## 2. 绕 Y 轴自转，使用 fmod 防止精度溢出
func _process(delta: float) -> void:
	position.x = sin(increment)
	position.z = cos(increment)
	# 使用 fmod 防止长时间运行后的精度问题。
	rotation.y = fmod(increment, TAU)

	increment += delta
