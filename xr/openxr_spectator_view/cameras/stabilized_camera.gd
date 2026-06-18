## 稳定相机节点 —— 提供 steadycam 效果的旁观者相机。
## 继承自 [Camera3D]，复制 XR 相机的视图并对物理移动进行平滑插值，
## 使旁观者画面更稳定易看。
extends Camera3D

## 要复制视图的 XRCamera3D 节点引用。
@export var xr_camera : XRCamera3D

## 是否去除相机俯仰角（pitch）。
@export var remove_pitch : bool = true

## 插值速度（1.0~60.0）。值越低越稳定但延迟越大。
@export_range(1.0, 60.0, 1.0) var lerp_speed : float = 10.0

## 上一帧的相机变换，用于插值计算。
var prev_camera_transform : Transform3D
## 是否为第一帧，第一帧不进行插值。
var first_frame : bool = true


## _process 每帧更新 —— 平滑跟随 XR 相机。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 在 XROrigin3D 的局部空间中进行平滑，避免对游戏逻辑移动进行平滑
##   2. 可选去除俯仰角
##   3. 使用 slerp 和 lerp 对旋转和位置进行插值
##   4. 应用变换到全局位置
func _process(delta):
	if current and xr_camera:
		# 在 XROrigin3D 的局部空间中进行平滑，
		# 这样不会对游戏逻辑移动应用平滑，只对物理移动平滑
		var camera_transform : Transform3D = xr_camera.transform

		if remove_pitch:
			# 去除相机俯仰角
			camera_transform.basis = Basis.looking_at(camera_transform.basis.z, Vector3.UP, true)

		if first_frame:
			first_frame = false
		else:
			# 对物理相机移动进行插值平滑
			camera_transform.basis = prev_camera_transform.basis.slerp(camera_transform.basis, delta * lerp_speed)
			camera_transform.origin = prev_camera_transform.origin.lerp(camera_transform.origin, delta * lerp_speed)

		# 更新第一人称视图
		global_transform = xr_camera.get_parent().global_transform * camera_transform

		# 保存当前变换供下一帧使用
		prev_camera_transform = camera_transform
	else:
		# 确保下次不进行插值
		first_frame = true
