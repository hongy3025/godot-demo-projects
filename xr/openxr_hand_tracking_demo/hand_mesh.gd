## 手部网格节点 —— 根据可用追踪源自动切换手部追踪器。
## 继承自 [XRNode3D]，优先使用手部追踪器，不可用时回退到控制器追踪器。
extends XRNode3D

## 手部（0=左手，1=右手）。
@export_enum("Left","Right") var hand : int = 0


## _process 每帧更新 —— 检测并切换到最佳追踪源。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 先检查手部追踪器是否有追踪数据
##   2. 如果有，切换到手部追踪器
##   3. 否则回退到控制器追踪器
##   4. 使用控制器追踪器时，优先使用 palm_pose，不可用时回退到 grip
func _process(delta):
	var new_tracker : String

	# 检查手部追踪器是否可用
	new_tracker = "/user/hand_tracker/left" if hand == 0 \
		else "/user/hand_tracker/right"
	var hand_tracker : XRHandTracker = XRServer.get_tracker(new_tracker)
	if hand_tracker and hand_tracker.has_tracking_data:
		if tracker != new_tracker:
			print("Switching to left hand tracker" if hand == 0 \
				else "Switching to right hand tracker")
			tracker = new_tracker
			pose = "default"

		return

	# 回退到控制器追踪器
	new_tracker = "left_hand" if hand == 0 else "right_hand"
	var controller_tracker : XRControllerTracker = XRServer.get_tracker(new_tracker)
	if controller_tracker:
		if tracker != new_tracker:
			print("Switching to left controller tracker" if hand == 0 \
				else "Switching to right controller tracker")
			tracker = new_tracker

		# 优先使用 palm_pose，不可用时回退到 grip
		var new_pose : String = "palm_pose"
		var xr_pose : XRPose = controller_tracker.get_pose(new_pose)
		if not xr_pose or xr_pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
			new_pose = "grip"

		if pose != new_pose:
			pose = new_pose
