## 手部信息显示节点 —— 在 3D 空间中显示手部追踪状态信息。
## 继承自 [Node3D]，从 [XRServer] 获取追踪器信息并显示在 [Label3D] 上。
extends Node3D

## 手部（0=左手，1=右手）。
@export_enum("Left", "Right") var hand : int = 0

## 回退网格节点，当手部无追踪数据时显示。
@export var fallback_mesh : Node3D


## _process 每帧更新 —— 查询追踪器状态并更新显示文本。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 显示信息包括:
##   - 手部名称
##   - 控制器追踪器配置文件和姿态
##   - 追踪置信度
##   - 手部追踪器数据源类型
func _process(delta):
	var text = ""

	if hand == 0:
		text += "Left hand\n"
	else:
		text += "Right hand\n"

	# 查询控制器追踪器信息
	var controller_tracker : XRPositionalTracker = XRServer.get_tracker(&"left_hand" if hand == 0 else &"right_hand")
	if controller_tracker:
		var profile = controller_tracker.profile.replace("/interaction_profiles/", "").replace("/", " ")
		text += "\nProfile: " + profile + "\n"

		# 检查 palm_pose 是否可用
		var pose : XRPose = controller_tracker.get_pose(&"palm_pose")
		if pose and pose.tracking_confidence != XRPose.XR_TRACKING_CONFIDENCE_NONE:
			text +=" - Using palm pose\n"
		else:
			pose = controller_tracker.get_pose(&"grip")
			if pose:
				text +=" - Using grip pose\n"

		# 显示追踪置信度
		if pose:
			if pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
				text += "- No tracking data\n"
			elif pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_LOW:
				text += "- Low confidence tracking data\n"
			elif pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_HIGH:
				text += "- High confidence tracking data\n"
			else:
				text += "- Unknown tracking data %d \n" % [ pose.tracking_confidence ]
		else:
			text += "- No pose data\n"
	else:
		text += "\nNo controller tracker found!\n"

	# 查询手部追踪器信息
	var hand_tracker : XRHandTracker = XRServer.get_tracker(&"/user/hand_tracker/left" if hand == 0 else &"/user/hand_tracker/right")
	if hand_tracker:
		text += "\nHand tracker found\n"

		# 显示手部追踪数据源
		if hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_UNKNOWN:
			text += "- Source: unknown\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_UNOBSTRUCTED:
			text += "- Source: optical hand tracking\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER:
			text += "- Source: inferred from controller\n"
		elif hand_tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_NOT_TRACKED:
			text += "- Source: no source\n"
		else:
			text += "- Source: %d\n" % [ hand_tracker.hand_tracking_source ]

		# 无追踪数据时显示回退网格
		if fallback_mesh:
			fallback_mesh.visible = not hand_tracker.has_tracking_data
	else:
		text += "\nNo hand tracker found!\n"

	$Info.text = text
