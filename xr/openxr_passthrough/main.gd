## 透视模式主节点 —— 管理 VR 与 AR（透视）模式的切换。
## 继承自 [Node3D]，通过 OpenXR 的环境混合模式在 VR 和 AR 之间切换。
extends Node3D

## 视口引用。
@onready var viewport: Viewport = get_viewport()
## 世界环境引用，用于控制背景渲染。
@onready var environment: Environment = $WorldEnvironment.environment
## 淡入淡出消息 3D 节点，用于显示提示信息。
@onready var fade_message : FadeMessage3D = $XROrigin3D/FadeMessage3D

## 当前是否启用了透视模式。
var passthrough_enabled: bool = false


## 切换到 AR（透视）模式。
## 返回: [bool] 是否成功切换
##
## 逻辑:
##   1. 获取 OpenXR 接口
##   2. 查询支持的环境混合模式
##   3. 优先使用 ALPHA_BLEND，回退到 ADDITIVE
##   4. 设置视口透明背景和环境颜色为透明
func switch_to_ar() -> bool:
	var xr_interface: OpenXRInterface = $StartVR.get_xr_interface()
	if not xr_interface:
		return false

	var modes = xr_interface.get_supported_environment_blend_modes()
	if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
	elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
	else:
		push_error("Passthrough not supported!")
		fade_message.text = "Passthrough is not supported on this device"
		return false

	viewport.transparent_bg = true
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	return true


## 切换到 VR（退出透视）模式。
## 返回: [bool] 是否成功切换
##
## 逻辑:
##   1. 获取 OpenXR 接口
##   2. 查询支持的环境混合模式
##   3. 使用 OPAQUE 模式
##   4. 恢复视口不透明背景和天空盒环境
func switch_to_vr() -> bool:
	var xr_interface: OpenXRInterface = $StartVR.get_xr_interface()
	if not xr_interface:
		return false

	var modes = xr_interface.get_supported_environment_blend_modes()
	if XRInterface.XR_ENV_BLEND_MODE_OPAQUE in modes:
		xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
	else:
		push_error("Opaque not supported!")
		fade_message.text = "Opaque mode is not supported on this device"
		return false

	viewport.transparent_bg = false
	environment.background_mode = Environment.BG_SKY
	return true


## OpenXR 会话开始回调 —— 启动时自动切换到透视模式。
func _on_start_vr_session_started():
	passthrough_enabled = switch_to_ar()


## 手柄按钮释放回调 —— 切换透视/VR 模式。
## 参数:
##   action_name: 操作名称
##
## 当按下 ax_button 时，在透视和 VR 模式之间切换。
func _on_button_released(action_name):
	if action_name == "ax_button":
		if passthrough_enabled:
			switch_to_vr()
			passthrough_enabled = false
		else:
			passthrough_enabled = switch_to_ar()
