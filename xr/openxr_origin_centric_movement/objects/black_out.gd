## 黑屏效果节点 —— 当玩家碰撞到障碍物时逐渐变暗屏幕。
## 继承自 [Node3D]，通过 [ShaderMaterial] 控制透明度实现渐变黑屏效果。
@tool
extends Node3D

## 黑屏透明度（0.0 ~ 1.0）。0 为完全透明（隐藏），1 为完全不透明。
## 设置时会自动更新材质和可见性。
@export_range(0, 1, 0.1) var fade := 0.0:
	set(value):
		fade = value
		if is_inside_tree():
			_update_fade()

## 材质引用，用于控制黑屏网格的透明度。
var material: ShaderMaterial


## 更新黑屏效果 —— 根据 [member fade] 值控制可见性和透明度。
## 当 fade 为 0 时隐藏网格，否则设置材质透明度并显示。
func _update_fade() -> void:
	if fade == 0.0:
		$MeshInstance3D.visible = false
	else:
		if material:
			material.set_shader_parameter(&"albedo", Color(0.0, 0.0, 0.0, fade))
		$MeshInstance3D.visible = true


## _ready 初始化 —— 获取材质引用并更新初始状态。
func _ready() -> void:
	material = $MeshInstance3D.material_override
	_update_fade()
