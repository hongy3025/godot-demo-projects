## HDR 色调映射演示 —— 球体和光源颜色循环。
##
## 继承自 [Node3D]，使光源和球体材质发射颜色在 HSV 色环上循环。
extends Node3D

## 颜色变化速度
@export var color_speed: float = 0.1

@onready var light: Light3D = $"OmniLight3D"
@onready var material: StandardMaterial3D = $"geodesic-sphere/GD_mesh_002".material_override as StandardMaterial3D

## 当前色相值 (0.0 ~ 1.0)
var current_hue: float = 0.0


## _process 入口，每帧更新色相并应用到光源和材质。
func _process(delta: float) -> void:
	current_hue += color_speed * delta
	if current_hue > 1.0:
		current_hue -= 1.0
	var new_color = Color.from_hsv(current_hue, 1.0, 1.0)
	light.light_color = new_color
	material.emission = new_color
