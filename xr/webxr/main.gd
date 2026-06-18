## WebXR 演示主节点 —— 在浏览器中初始化 WebXR 并处理 VR 交互。
## 继承自 [Node3D]，处理 WebXR 会话生命周期、控制器输入和选择/挤压事件。
extends Node3D

## WebXR 接口实例，通过 [XRServer] 查找获取。
var webxr_interface: WebXRInterface
## VR 是否受浏览器支持。
var vr_supported: bool = false

## 左手柄控制器节点引用。
@onready var left_controller = $XROrigin3D/LeftController


## _ready 初始化 —— 连接 WebXR 信号和控制器事件。
## 查找 WebXR 接口，连接会话支持和选择/挤压事件信号，
## 查询浏览器是否支持 immersive-vr 模式。
func _ready() -> void:
	$CanvasLayer/EnterVRButton.pressed.connect(_on_enter_vr_button_pressed)

	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		# WebXR 使用异步回调，连接各种信号接收事件
		webxr_interface.session_supported.connect(_webxr_session_supported)
		webxr_interface.session_started.connect(_webxr_session_started)
		webxr_interface.session_ended.connect(_webxr_session_ended)
		webxr_interface.session_failed.connect(_webxr_session_failed)

		webxr_interface.select.connect(_webxr_on_select)
		webxr_interface.selectstart.connect(_webxr_on_select_start)
		webxr_interface.selectend.connect(_webxr_on_select_end)

		webxr_interface.squeeze.connect(_webxr_on_squeeze)
		webxr_interface.squeezestart.connect(_webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(_webxr_on_squeeze_end)

		# 查询浏览器是否支持 immersive-vr 模式
		webxr_interface.is_session_supported("immersive-vr")

	# 连接左手柄按钮事件
	$XROrigin3D/LeftController.button_pressed.connect(_on_left_controller_button_pressed)
	$XROrigin3D/LeftController.button_released.connect(_on_left_controller_button_released)


## WebXR 会话支持回调 —— 接收浏览器对 VR 模式的支持情况。
## 参数:
##   session_mode: 会话模式字符串
##   supported: 是否支持
func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == "immersive-vr":
		vr_supported = supported


## 进入 VR 按钮点击回调 —— 请求 WebXR immersive-vr 会话。
## 检查浏览器支持情况，设置会话模式和参考空间类型，
## 然后初始化 WebXR 接口。
func _on_enter_vr_button_pressed() -> void:
	if not vr_supported:
		OS.alert("Your browser doesn't support VR")
		return

	# 设置会话模式为 immersive-vr（沉浸式 VR）
	webxr_interface.session_mode = "immersive-vr"
	# 设置参考空间类型：优先 bounded-floor（房间尺度），
	# 回退到 local-floor（站立/坐姿），最后 local（仅定位）
	webxr_interface.requested_reference_space_types = "bounded-floor, local-floor, local"
	# 必需功能和可选功能
	webxr_interface.required_features = "local-floor"
	webxr_interface.optional_features = "bounded-floor"

	# 初始化 WebXR，可能异步失败
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return


## WebXR 会话开始回调 —— 隐藏 UI 并启用 XR 渲染。
func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	# 告诉 Godot 开始渲染到头显
	get_viewport().use_xr = true
	# 输出最终使用的参考空间类型
	print("Reference space type: " + webxr_interface.reference_space_type)
	# 输出成功启用的功能列表
	print("Enabled features: ", webxr_interface.enabled_features)


## WebXR 会话结束回调 —— 显示 UI 并禁用 XR 渲染。
func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	# 用户退出沉浸模式，恢复渲染到网页
	get_viewport().use_xr = false


## WebXR 会话失败回调 —— 显示错误提示。
## 参数:
##   message: 错误信息
func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)


## 左手柄按钮按下回调。
## 参数:
##   button: 按下的按钮名称
func _on_left_controller_button_pressed(button: String) -> void:
	print("Button pressed: " + button)


## 左手柄按钮释放回调。
## 参数:
##   button: 释放的按钮名称
func _on_left_controller_button_released(button: String) -> void:
	print("Button release: " + button)


## _process 每帧更新 —— 读取左手柄摇杆输入并打印。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
func _process(_delta: float) -> void:
	var thumbstick_vector: Vector2 = left_controller.get_vector2(&"thumbstick")
	if thumbstick_vector != Vector2.ZERO:
		print("Left thumbstick position: " + str(thumbstick_vector))


## WebXR 选择事件回调 —— 触发选择操作时调用。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_select(input_source_id: int) -> void:
	print("Select: " + str(input_source_id))

	var tracker: XRControllerTracker = webxr_interface.get_input_source_tracker(input_source_id)
	var xform: Transform3D = tracker.get_pose(&"default").transform
	print(xform.origin)


## WebXR 选择开始事件回调。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_select_start(input_source_id: int) -> void:
	print("Select Start: " + str(input_source_id))


## WebXR 选择结束事件回调。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_select_end(input_source_id: int) -> void:
	print("Select End: " + str(input_source_id))


## WebXR 挤压事件回调。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_squeeze(input_source_id: int) -> void:
	print("Squeeze: " + str(input_source_id))


## WebXR 挤压开始事件回调。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_squeeze_start(input_source_id: int) -> void:
	print("Squeeze Start: " + str(input_source_id))


## WebXR 挤压结束事件回调。
## 参数:
##   input_source_id: 输入源 ID
func _webxr_on_squeeze_end(input_source_id: int) -> void:
	print("Squeeze End: " + str(input_source_id))
