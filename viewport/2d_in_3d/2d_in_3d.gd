## 2D 嵌入 3D 演示 —— 将 2D 游戏渲染到 SubViewport 并显示在 3D 场景的 Quad 上。
##
## 继承自 [Node3D]，管理 SubViewport 和 3D Quad 之间的纹理映射，
## 并为摄像机添加微弱的待机摆动动画。
extends Node3D

## 摄像机待机动画的摆动幅度系数。
const CAMERA_IDLE_SCALE = 0.005

## 计时器，用于驱动摄像机待机动画。
var counter := 0.0
## 摄像机的初始旋转角度，用于待机动画的基准值。
@onready var camera_base_rotation: Vector3 = $Camera3D.rotation

## 初始化：设置 SubViewport 的清除模式为"仅清除一次"，
## 并将 SubViewport 的纹理设置到 ViewportQuad 的材质上。
func _ready() -> void:
	var viewport: SubViewport = $SubViewport
	# 设置为仅在首次渲染时清除，之后保留渲染结果
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE

	# 将子视口的纹理绑定到 3D Quad 的材质上
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()


## 每帧更新：为摄像机添加待机摆动动画。
## 使用正弦/余弦函数让摄像机在三个轴上做微幅摆动，产生呼吸感。
func _process(delta: float) -> void:
	counter += delta
	$Camera3D.rotation.x = camera_base_rotation.y + cos(counter) * CAMERA_IDLE_SCALE
	$Camera3D.rotation.y = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
	$Camera3D.rotation.z = camera_base_rotation.y + sin(counter) * CAMERA_IDLE_SCALE
