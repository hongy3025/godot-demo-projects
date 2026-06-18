## 旁观者自由相机节点 —— 可在场景中自由定位的旁观者相机。
## 继承自 [Camera3D]，支持定位开关、自动注视目标和相机画面显示。
extends Camera3D

## 是否启用自由定位。关闭时由跟踪器控制位置。
@export var enable_positioning: bool = true:
	set(value):
		if enable_positioning == value:
			return

		enable_positioning = value
		if is_inside_tree():
			$Area3D/CollisionShape3D.disabled = not enable_positioning
			if enable_positioning:
				# 重新启用时恢复到上次保存的位置
				global_transform = last_transform

## 相机应注视的目标节点。
@export var lookat_node: Node3D

## 上次保存的变换，用于重新启用定位时恢复位置。
@onready var last_transform: Transform3D = global_transform
## 相机机身上的显示屏幕，用于显示视口画面。
@onready var display: MeshInstance3D = $CameraBody/DisplayContainer/Display


## _ready 初始化 —— 设置相机画面显示材质。
func _ready():
	var material: ShaderMaterial = display.material_override
	if material:
		material.set_shader_parameter(&"albedo_texture", get_viewport().get_texture())


## _process 每帧更新 —— 注视目标节点并保存位置。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
##
## 如果启用了定位，自动注视 [member lookat_node] 并保存当前变换。
func _process(_delta):
	if not enable_positioning:
		return

	# 确保相机朝向目标方向
	if lookat_node:
		look_at(lookat_node.global_position, Vector3.UP, false)

	# 保存当前变换
	last_transform = global_transform
