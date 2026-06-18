## 移动 VR 接口演示主节点 —— 初始化原生移动 VR 并处理基本移动输入。
## 继承自 [Node3D]，使用 [MobileVRInterface] 在移动设备上实现 VR 功能。
extends Node3D

## 移动 VR 接口实例，通过 [XRServer] 查找获取。
var xr_interface : MobileVRInterface


## _ready 初始化 —— 查找并初始化移动 VR 接口。
## 如果成功则启用 XR 渲染和可变速率着色，否则退出游戏。
func _ready():
	xr_interface = XRServer.find_interface("Native mobile")
	if xr_interface and xr_interface.initialize():
		# 设置视口
		var vp = get_viewport()
		vp.use_xr = true
		vp.vrs_mode = Viewport.VRS_XR
	else:
		# 初始化失败，退出游戏
		get_tree().quit()


## _process 每帧更新 —— 处理方向键输入并移动 XROrigin3D。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 读取 UI 方向键输入，沿 XROrigin3D 的局部坐标系移动玩家位置。
func _process(delta):
	var dir : Vector2 = Vector2()

	# 读取方向键输入
	if Input.is_action_pressed(&"ui_left"):
		dir.x = -1.0
	elif Input.is_action_pressed(&"ui_right"):
		dir.x = 1.0
	if Input.is_action_pressed(&"ui_up"):
		dir.y = -1.0
	elif Input.is_action_pressed(&"ui_down"):
		dir.y = 1.0

	# 沿 XROrigin3D 的局部坐标系移动
	$XROrigin3D.global_position += $XROrigin3D.global_transform.basis.x * dir.x * delta
	$XROrigin3D.global_position += $XROrigin3D.global_transform.basis.z * dir.y * delta
