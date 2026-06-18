## 旁观者视图主场景节点 —— 管理 XR 指针切换和相机跟踪。
## 继承自 [Node3D]，处理左右手柄指针切换和跟踪相机远程变换。
extends Node3D

## 跟踪相机节点引用。设置后自动更新 [RemoteTransform3D] 的远程路径。
@export var tracked_camera : Node3D:
	set(value):
		tracked_camera = value
		if tracked_camera:
			%CameraRemoteTransform3D.remote_path = tracked_camera.get_path()
		else:
			%CameraRemoteTransform3D.remote_path = NodePath()

## 当前启用的指针方向（0=左手，1=右手）。
var left_or_right: int = 1


## 启用最后按下按钮的手对应的指针。
func _enable_pointer():
	$XROrigin3D/LeftHandAim/XRPointer.enabled = left_or_right == 0
	$XROrigin3D/RightHandAim/XRPointer.enabled = left_or_right == 1


## _ready 初始化 —— 启用默认指针。
func _ready():
	_enable_pointer()


## 左手柄按钮按下回调 —— 切换到左手指针。
func _on_left_hand_aim_button_pressed(_name):
	if left_or_right != 0:
		left_or_right = 0
		_enable_pointer()


## 右手柄按钮按下回调 —— 切换到右手指针。
func _on_right_hand_aim_button_pressed(_name):
	if left_or_right != 1:
		left_or_right = 1
		_enable_pointer()
