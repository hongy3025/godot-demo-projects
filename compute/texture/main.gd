## 水面波纹演示场景的主控制节点。
##
## 继承自 [Node3D]，提供 UI 控制界面来调整水面波纹效果的参数。
## 核心实现请参考 [water_plane.gd]。
extends Node3D

## 水面旋转角度累计值（弧度）
var y := 0.0

## 水面平面节点引用
@onready var water_plane: Area3D = $WaterPlane


## _ready 入口。初始化 UI 控件的值，使其与水面节点的当前参数同步。
func _ready() -> void:
	$Container/RainSize/HSlider.value = $WaterPlane.rain_size
	$Container/MouseSize/HSlider.value = $WaterPlane.mouse_size


## 每帧更新。如果旋转按钮被按下，则绕 Y 轴旋转水面平面。
##
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
func _process(delta: float) -> void:
	if $Container/Rotate.button_pressed:
		y += delta
		water_plane.basis = Basis(Vector3.UP, y)


## 雨滴大小滑块值变化时的回调。更新水面节点的雨滴大小参数。
##
## 参数:
##   value: 滑块的新值
func _on_rain_size_changed(value: float) -> void:
	$WaterPlane.rain_size = value


## 鼠标波纹大小滑块值变化时的回调。更新水面节点的鼠标波纹大小参数。
##
## 参数:
##   value: 滑块的新值
func _on_mouse_size_changed(value: float) -> void:
	$WaterPlane.mouse_size = value
