## HDR 闪光编排器 —— 按顺序触发多个网格的 HDR 颜色闪光。
##
## 继承自 [Node3D]，管理一组 MeshInstance3D，按时间间隔依次触发闪光。
extends Node3D

## 基础颜色数组
@export var base_colors: Array[Color]
## 网格实例数组
@export var meshes: Array[MeshInstance3D]
## 闪光间隔时间
@export var time_between_flashes: float = 0.2

## 已过时间
var _time_passed: float = 0.0
## 当前网格索引
var _mesh_index: int = 0


## _ready 入口，初始化网格颜色并附加 ColorFlash 脚本。
func _ready() -> void:
	seed(0)
	meshes.shuffle()

	var color_index = 0

	for mesh in meshes:
		color_index += 1
		if color_index >= base_colors.size():
			color_index = 0

		var material: StandardMaterial3D = mesh.get_active_material(0).duplicate() as StandardMaterial3D
		material.albedo_color = base_colors[color_index]
		mesh.material_override = material
		mesh.set_script(preload("res://output_max_linear_value/color_flash.gd"))


## _process 入口，每帧检测是否触发下一个网格的闪光。
func _process(delta: float) -> void:
	_time_passed += delta
	if _time_passed > time_between_flashes:
		meshes[_mesh_index].flash()
		_mesh_index += 1
		if _mesh_index >= meshes.size():
			_mesh_index = 0
		_time_passed -= time_between_flashes
