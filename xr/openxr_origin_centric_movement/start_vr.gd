## OpenXR 启动节点 —— 初始化 OpenXR 接口并管理 XR 会话生命周期。
## 继承自 [Node3D]，负责查找并初始化 OpenXR 接口、配置视口、
## 设置可变速率着色、连接 OpenXR 会话事件信号。
extends Node3D

## 会话开始信号 —— 当 OpenXR 会话完成初始化并开始运行时触发。
signal session_started
## 焦点丢失信号 —— 当用户摘下头显或 XR 会话失去焦点时触发。
signal focus_lost
## 焦点获得信号 —— 当 XR 会话获得焦点时触发。
signal focus_gained
## 姿态重定中心信号 —— 当用户重定中心视图时触发。
signal pose_recentered

## 最大刷新率上限。我们会从支持的刷新率中选择不超过此值的最优值。
@export var maximum_refresh_rate: int = 90

## OpenXR 接口实例，通过 [XRServer] 查找获取。
var xr_interface: OpenXRInterface
## XR 是否处于聚焦状态。用于跟踪会话可见/聚焦状态切换。
var xr_is_focused: bool = false


## 获取 OpenXR 接口实例。
## 返回: [OpenXRInterface] 当前初始化的 OpenXR 接口
func get_xr_interface() -> OpenXRInterface:
	return xr_interface


## _ready 入口 —— 初始化 OpenXR 并配置视口。
## 查找 OpenXR 接口，如果已初始化则启用 XR 渲染、关闭垂直同步、
## 启用可变速率着色（VRS），并连接所有 OpenXR 会话事件信号。
## 如果 OpenXR 未初始化则退出游戏。
func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR instantiated successfully.")
		var vp: Viewport = get_viewport()

		# 在视口上启用 XR 渲染
		vp.use_xr = true

		# 关闭垂直同步，因为 OpenXR 自行管理垂直同步
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# 启用可变速率着色（VRS）
		if RenderingServer.get_rendering_device():
			vp.vrs_mode = Viewport.VRS_XR
		elif int(ProjectSettings.get_setting("xr/openxr/foveation_level")) == 0:
			push_warning("OpenXR: Recommend setting Foveation level to High in Project Settings")

		# 连接 OpenXR 事件信号
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
	else:
		# OpenXR 初始化失败，退出游戏
		print("OpenXR not instantiated!")
		get_tree().quit()


## OpenXR 会话开始回调 —— 获取并优化刷新率，同步物理帧率。
## 查询当前刷新率和可用刷新率列表，选择不超过 [member maximum_refresh_rate] 的最优值，
## 然后将物理帧率设置为匹配刷新率，避免因物理插值未启用导致的抖动。
## 最后发射 [signal session_started] 信号。
func _on_openxr_session_begun() -> void:
	# 获取当前刷新率
	var current_refresh_rate := xr_interface.get_display_refresh_rate()
	if current_refresh_rate > 0:
		print("OpenXR: Refresh rate reported as ", str(current_refresh_rate))
	else:
		print("OpenXR: No refresh rate given by XR runtime")

	# 查找是否有更优的可用刷新率
	var new_rate := current_refresh_rate
	var available_rates: Array = xr_interface.get_available_display_refresh_rates()
	if available_rates.is_empty():
		print("OpenXR: Target does not support refresh rate extension")
	elif available_rates.size() == 1:
		# 只有一个可用值，直接使用
		new_rate = available_rates[0]
	else:
		for rate in available_rates:
			if rate > new_rate and rate <= maximum_refresh_rate:
				new_rate = rate

	# 如果找到更优刷新率则设置
	if current_refresh_rate != new_rate:
		print("OpenXR: Setting refresh rate to ", str(new_rate))
		xr_interface.set_display_refresh_rate(new_rate)
		current_refresh_rate = new_rate

	# 将物理帧率与刷新率匹配，避免抖动
	Engine.physics_ticks_per_second = roundi(current_refresh_rate)

	session_started.emit()


## OpenXR 可见状态回调 —— 处理会话变为可见（或用户摘头显）。
## 首次启动时也会经过此状态，第二次触发意味着用户摘下了头显，
## 此时暂停游戏并发射 [signal focus_lost] 信号。
func _on_openxr_visible_state() -> void:
	if xr_is_focused:
		print("OpenXR lost focus")

		xr_is_focused = false

		# 暂停游戏
		process_mode = Node.PROCESS_MODE_DISABLED

		focus_lost.emit()


## OpenXR 聚焦状态回调 —— 处理会话获得焦点。
## 恢复游戏运行并发射 [signal focus_gained] 信号。
func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focused = true

	# 恢复游戏运行
	process_mode = Node.PROCESS_MODE_INHERIT

	focus_gained.emit()


## OpenXR 停止状态回调 —— 处理会话正在停止的事件。
func _on_openxr_stopping() -> void:
	print("OpenXR is stopping")


## OpenXR 姿态重定中心回调 —— 处理用户重定中心视图。
## 发射 [signal pose_recentered] 信号，由具体游戏逻辑处理重定中心。
func _on_openxr_pose_recentered() -> void:
	pose_recentered.emit()
