## XR 手部回退修改器 —— 当手部追踪不可用时，使用控制器输入驱动手指动画。
## 使用类名注册为 [code]XRHandFallbackModifier3D[/code]。
## 继承自 [SkeletonModifier3D]，当 XR 运行时不支持手部追踪或数据源不可用时，
## 使用扳机和握持输入分别驱动食指和其余三指的动画。
class_name XRHandFallbackModifier3D
extends SkeletonModifier3D

## 用于驱动食指动画的操作名称（通常为扳机）。
@export var trigger_action : String = "trigger"

## 用于驱动底部三指动画的操作名称（通常为握持）。
@export var grip_action : String = "grip"


## _process_modification 骨骼修改回调 —— 根据控制器输入驱动手指骨骼。
## 逻辑:
##   1. 获取骨骼和父 XRNode3D
##   2. 如果已有手部追踪器则跳过（不需要回退）
##   3. 从追踪器读取扳机和握持值
##   4. 根据骨骼名称设置对应的旋转角度
func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return

	# 查找父 XRNode3D
	var parent = get_parent()
	while parent and not parent is XRNode3D:
		parent = parent.get_parent()
	if !parent:
		return

	# 检查是否有活跃的手部追踪器，有则不需要回退
	var xr_parent : XRNode3D = parent
	if not xr_parent.tracker in [ "left_hand", "right_hand" ]:
		return

	var trigger : float = 0.0
	var grip : float = 0.0

	# 从追踪器读取扳机和握持值
	var tracker : XRControllerTracker = XRServer.get_tracker(xr_parent.tracker)
	if tracker:
		var trigger_value : Variant = tracker.get_input(trigger_action)
		if trigger_value:
			trigger = trigger_value

		var grip_value : Variant = tracker.get_input(grip_action)
		if grip_value:
			grip = grip_value

	# 遍历所有骨骼并设置姿态
	var bone_count = skeleton.get_bone_count()
	for i in bone_count:
		var t : Transform3D = skeleton.get_bone_rest(i)

		# 根据骨骼名称驱动动画
		var bone_name = skeleton.get_bone_name(i)
		if bone_name == "LeftHand":
			# 偏移手掌中心，需要使用手掌姿态
			t.origin += Vector3(-0.015, 0.0, 0.04)
		elif bone_name == "RightHand":
			# 偏移手掌中心，需要使用手掌姿态
			t.origin += Vector3(0.015, 0.0, 0.04)
		elif bone_name == "LeftIndexDistal" or bone_name == "LeftIndexIntermediate" \
			or bone_name == "RightIndexDistal" or bone_name == "RightIndexIntermediate":
			# 食指远节和中节：根据扳机值旋转 45 度
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(45.0) * trigger)
		elif bone_name == "LeftIndexProximal" or bone_name == "RightIndexProximal":
			# 食指近节：根据扳机值旋转 20 度
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(20.0) * trigger)
		elif bone_name == "LeftMiddleDistal" or bone_name == "LeftMiddleIntermediate" or bone_name == "LeftMiddleProximal" \
				or bone_name == "RightMiddleDistal" or bone_name == "RightMiddleIntermediate" or bone_name == "RightMiddleProximal" \
				or bone_name == "LeftRingDistal" or bone_name == "LeftRingIntermediate" or bone_name == "LeftRingProximal" \
				or bone_name == "RightRingDistal" or bone_name == "RightRingIntermediate" or bone_name == "RightRingProximal" \
				or bone_name == "LeftLittleDistal" or bone_name == "LeftLittleIntermediate" or bone_name == "LeftLittleProximal" \
				or bone_name == "RightLittleDistal" or bone_name == "RightLittleIntermediate" or bone_name == "RightLittleProximal":
			# 中指、无名指、小指的所有指节：根据握持值旋转 90 度
			var r : Transform3D
			t = t * r.rotated(Vector3(1.0, 0.0, 0.0), deg_to_rad(90.0) * grip)

		skeleton.set_bone_pose(i, t)
