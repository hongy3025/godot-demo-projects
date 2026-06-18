## 手部控制器节点 —— 自动选择最佳姿态（palm_pose 或 grip）。
## 继承自 [XRController3D]，每帧检查 palm_pose 是否可用，
## 不可用时回退到 grip 姿态。
extends XRController3D


## _process 每帧更新 —— 检查并切换到手部最佳姿态。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 优先使用 palm_pose（手掌姿态），如果不可用或追踪置信度为 NONE，
## 则回退到 grip（握持姿态）。
func _process(delta):
	var controller_tracker : XRControllerTracker = XRServer.get_tracker(tracker)
	if controller_tracker:
		var new_pose : String = "palm_pose"
		var xr_pose : XRPose = controller_tracker.get_pose(new_pose)
		if not xr_pose or xr_pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
			new_pose = "grip"

		if pose != new_pose:
			pose = new_pose
