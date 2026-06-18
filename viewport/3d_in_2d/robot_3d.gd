## 3D 模型旋转控制器 —— 让 3D 模型在 2D 场景中持续旋转展示。
##
## 继承自 [Node]，控制子节点 $Model 的旋转。
## 用于在 2D 场景中展示 3D 模型的旋转预览效果。
extends Node

## 3D 模型节点的引用。
@onready var model: Node3D = $Model


## 每帧更新：让模型绕 Y 轴持续旋转。
## 参数:
##   delta: 帧时间差（秒）
## 旋转速度约为 0.7 弧度/秒。
func _process(delta: float) -> void:
	model.rotation.y += delta * 0.7
