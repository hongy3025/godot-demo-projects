## 旁观者视图 UI 节点 —— 在 2D 画布上显示 VR 旁观者控制界面。
## 继承自 [Node2D]，管理 HMD 视图显示、视角切换、相机跟踪和缩放控制。
extends Node2D

## 主视口引用。
var main_viewport: Viewport
## VR 渲染尺寸。
var vr_render_size: Vector2 = Vector2()
## 窗口尺寸。
var window_size: Vector2 = Vector2()
## HMD 视图着色材质引用。
var hmd_view_material: ShaderMaterial

## HMD 视图显示节点（[ColorRect]）。
@onready var hmd_view: ColorRect = $HMDView
## 旁观者视角下拉选择器。
@onready var ui_spectator_view: OptionButton = $UI/SpectatorView
## 跟踪相机复选框。
@onready var ui_track_camera: CheckBox = $UI/TrackCamera
## 缩放滑动条。
@onready var ui_zoom_slider: HSlider = $UI/ZoomSlider
## 旁观者自由相机。
@onready var spectator_camera: Camera3D = $SpectatorCamera
## 稳定相机（steadycam 效果）。
@onready var stabilized_camera: Camera3D = $StabilizedCamera
## VR 子视口，用于渲染 HMD 画面。
@onready var vr_viewport: SubViewport = $VRSubViewport
## VR 主场景节点。
@onready var main_scene: Node3D = $VRSubViewport/Main
## VR 启动节点。
@onready var start_vr = $VRSubViewport/Main/StartVR


## 重新定位 HMD 视图纹理矩形 —— 根据窗口尺寸和缩放值计算位置和大小。
func _reposition_texture_rect():
	if window_size != Vector2() and vr_render_size != Vector2():
		var size = vr_render_size * ui_zoom_slider.value
		hmd_view.size = size
		hmd_view.position = (window_size - size) * 0.5


## 窗口尺寸变化回调 —— 更新窗口尺寸并重新定位 HMD 视图。
func _on_size_changed():
	window_size = get_tree().get_root().size
	_reposition_texture_rect()


## _ready 初始化 —— 设置视口、材质、信号连接和默认视图。
func _ready():
	# 获取主视口
	main_viewport = get_viewport()

	# 禁用兼容渲染模式下不可用的选项
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		ui_spectator_view.set("popup/item_2/disabled", true)
		ui_spectator_view.set("popup/item_3/disabled", true)

	# 获取 HMD 视图材质
	hmd_view_material = hmd_view.material

	# 连接窗口尺寸变化信号
	get_tree().get_root().size_changed.connect(_on_size_changed)

	# 初始化窗口尺寸
	_on_size_changed()

	# 选择默认视角模式
	_on_spectator_view_item_selected(ui_spectator_view.selected)

	# 设置跟踪相机初始状态
	_on_track_camera_toggled(ui_track_camera.button_pressed)


## OpenXR 会话开始回调 —— 获取 VR 渲染尺寸并重新定位 HMD 视图。
func _on_main_session_begun():
	vr_render_size = start_vr.get_vr_render_size()
	_reposition_texture_rect()


## 视角模式选择回调 —— 切换不同的旁观者视角。
## 参数:
##   index: 视角模式索引
##     0 - 旁观者自由相机
##     1 - 稳定相机（steadycam）
##     2 - 左眼视图
##     3 - 右眼视图
func _on_spectator_view_item_selected(index):
	match index:
		0: # 旁观者自由相机
			main_viewport.disable_3d = false
			spectator_camera.visible = true
			spectator_camera.current = true
			hmd_view.visible = false
			ui_track_camera.visible = true
			ui_zoom_slider.visible = false
		1: # 稳定相机（steadycam）
			main_viewport.disable_3d = false
			spectator_camera.visible = false
			stabilized_camera.current = true
			hmd_view.visible = false
			ui_track_camera.visible = false
			ui_zoom_slider.visible = false
		2: # 左眼视图
			main_viewport.disable_3d = true
			spectator_camera.visible = false
			hmd_view.visible = true
			ui_track_camera.visible = false
			ui_zoom_slider.visible = true
			if hmd_view_material:
				var vp_texture = vr_viewport.get_texture()
				hmd_view_material.set_shader_parameter(&"xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter(&"layer", 0)
		3: # 右眼视图
			main_viewport.disable_3d = true
			spectator_camera.visible = false
			hmd_view.visible = true
			ui_track_camera.visible = false
			ui_zoom_slider.visible = true
			if hmd_view_material:
				var vp_texture = vr_viewport.get_texture()
				hmd_view_material.set_shader_parameter(&"xr_texture", vp_texture)
				hmd_view_material.set_shader_parameter(&"layer", 1)


## 跟踪相机开关回调 —— 切换旁观者相机是否跟随 XR 跟踪器。
## 参数:
##   toggled_on: 是否开启跟踪
func _on_track_camera_toggled(toggled_on):
	if toggled_on:
		# 开启跟踪，由跟踪器控制位置
		spectator_camera.enable_positioning = false
		main_scene.tracked_camera = spectator_camera
	else:
		# 关闭跟踪，用户可自由定位相机
		spectator_camera.enable_positioning = true
		main_scene.tracked_camera = null


## 缩放滑块值变化回调 —— 重新定位 HMD 视图。
func _on_zoom_slider_value_changed(_value):
	_reposition_texture_rect()
