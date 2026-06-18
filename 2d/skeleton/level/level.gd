## 关卡节点 —— 设置摄像机边界限制。
## 继承自 Node2D，在 _ready 时根据两个 Marker2D 的位置设置 Camera2D 的视野范围。
extends Node2D

func _ready() -> void:
	var camera: Camera2D = find_child("Camera2D")
	# 使用两个标记点定义摄像机边界矩形
	var min_pos: Vector2 = $CameraLimit_min.global_position
	var max_pos: Vector2 = $CameraLimit_max.global_position
	# 设置摄像机上下左右边界（取整避免子像素偏移）
	camera.limit_left = round(min_pos.x)
	camera.limit_top = round(min_pos.y)
	camera.limit_right = round(max_pos.x)
	camera.limit_bottom = round(max_pos.y)
