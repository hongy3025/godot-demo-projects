## 图形设置演示场景的主控制器。
##
## 继承自 [Control]，提供完整的图形质量设置 UI，包括：
## - 视频设置（UI 缩放、渲染质量、滤镜、垂直同步、帧率限制、MSAA、TAA、SSAA、全屏、FOV）
## - 质量设置（阴影大小/过滤、网格 LOD）
## - 特效设置（SSR、SSAO、SSIL、SDFGI、辉光、体积雾）
## - 画面调节（亮度、对比度、饱和度）
## - 质量预设（极低/低/中/高/超高）
extends Control


# 窗口项目设置：
#  - 拉伸模式设置为 `canvas_items`（Godot 3.x 中的 `2d`）
#  - 拉伸宽高比设置为 `expand`
@onready var world_environment := $WorldEnvironment
@onready var directional_light := $Node3D/DirectionalLight3D
@onready var camera := $Node3D/Camera3D
@onready var fps_label := $FPSLabel
@onready var resolution_label := $ResolutionLabel

## 计时器计数器，用于延迟显示 FPS。
var counter: float = 0.0

# 当屏幕尺寸变化时，需要更新 3D 视口质量设置。
# 如果不这样做，视口会从主视口获取尺寸。
var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)

## 是否为兼容渲染模式。
var is_compatibility: bool = false


## _ready 入口。初始化兼容模式适配、视口尺寸监听和 V-Sync 设置。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		is_compatibility = true
		%UnsupportedLabel.visible = true
		mark_as_unsupported(%FilterOptionButton)
		mark_as_unsupported(%TAAOptionButton)
		mark_as_unsupported(%ScreenSpaceAAOptionButton)
		mark_as_unsupported(%SDFGIOptionButton)
		mark_as_unsupported(%SSAOOptionButton)
		mark_as_unsupported(%SSReflectionsOptionButton)
		mark_as_unsupported(%SSILOptionButton)
		mark_as_unsupported(%VolumetricFogOptionButton)
		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$Node3D/OmniLight3D.light_energy = 0.5
		$Node3D/SpotLight3D.light_energy = 0.5
		$Node3D/DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $Node3D/DirectionalLight3D.duplicate()
		new_light.light_energy = 0.35
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		$Node3D.add_child(new_light)

	get_viewport().size_changed.connect(update_resolution_label)
	update_resolution_label()

	# 禁用垂直同步以解除帧率上限，方便在高配机器上对比性能。
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## _process 入口。每帧更新 FPS 显示和颜色。
##
## 参数:
##   delta: 帧时间间隔
##
## FPS 标签在启动后 1 秒才显示（等待引擎首次更新 FPS 数据）。
## 根据帧率用渐变色为 FPS 着色。
func _process(delta: float) -> void:
	counter += delta
	# 隐藏 FPS 标签直到引擎首次更新（最多需要 1 秒）。
	fps_label.visible = counter >= 1.0
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	# 根据帧率为 FPS 计数器着色。
	# Gradient 资源存储在 FPSLabel 节点的 metadata 中（可在检查器中查看）。
	fps_label.modulate = fps_label.get_meta(&"gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))


## 更新视口分辨率显示文本。
func update_resolution_label() -> void:
	var viewport_render_size = get_viewport().size * get_viewport().scaling_3d_scale
	resolution_label.text = "3D 视口分辨率: %d × %d (%d%%)" \
			% [viewport_render_size.x, viewport_render_size.y, round(get_viewport().scaling_3d_scale * 100)]


## 隐藏/显示设置面板的切换回调。
##
## 参数:
##   show_settings: 是否显示设置面板
func _on_HideShowButton_toggled(show_settings: bool) -> void:
	var button := $HideShowButton
	var settings_menu := $SettingsMenu
	if show_settings:
		button.text = "隐藏设置"
	else:
		button.text = "显示设置"
	settings_menu.visible = show_settings

# 视频设置。

## UI 缩放选项选择回调。
##
## 参数:
##   index: 缩放级别索引（更小/小/中/大/更大）
func _on_ui_scale_option_button_item_selected(index: int) -> void:
	var new_size := viewport_start_size
	if index == 0: # 更小（66%）
		new_size *= 1.5
	elif index == 1: # 小（80%）
		new_size *= 1.25
	elif index == 2: # 中（100%）（默认）
		new_size *= 1.0
	elif index == 3: # 大（133%）
		new_size *= 0.75
	elif index == 4: # 更大（200%）
		new_size *= 0.5
	get_tree().root.set_content_scale_size(new_size)


## 渲染质量滑块值变化回调。
##
## 参数:
##   value: 渲染缩放比例（0~1）
func _on_quality_slider_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value
	update_resolution_label()


## 缩放过滤模式选择回调。
##
## 参数:
##   index: 过滤模式索引（双线性/FSR 1.0/FSR 2.2）
func _on_filter_option_button_item_selected(index: int) -> void:
	if index == 0: # 双线性（最快）
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		%FSRSharpnessLabel.visible = false
		%FSRSharpnessSlider.visible = false
	elif index == 1: # FSR 1.0（快）
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		%FSRSharpnessLabel.visible = true
		%FSRSharpnessSlider.visible = true
	elif index == 2: # FSR 2.2（快）
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		%FSRSharpnessLabel.visible = true
		%FSRSharpnessSlider.visible = true


## FSR 锐度滑块值变化回调。
##
## 参数:
##   value: 锐度值（滑块值越高画面越锐利，内部取反）
func _on_fsr_sharpness_slider_value_changed(value: float) -> void:
	# FSR 锐度值越低画面越锐利。
	# 反转滑块使值越高画面越锐利，符合用户预期。
	get_viewport().fsr_sharpness = 2.0 - value


## 垂直同步模式选择回调。
##
## 参数:
##   index: V-Sync 模式索引
func _on_vsync_option_button_item_selected(index: int) -> void:
	match index:
		0: # 禁用（默认）
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1: # 自适应
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2: # 启用
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


## 帧率限制滑块值变化回调。
##
## 参数:
##   value: 目标帧率（0 表示无限制）
func _on_fps_limit_slider_value_changed(value: float):
	Engine.max_fps = roundi(value)


## MSAA 模式选择回调。
##
## 参数:
##   index: MSAA 采样倍数索引
func _on_msaa_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif index == 1: # 2×
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif index == 2: # 4×
		get_viewport().msaa_3d = Viewport.MSAA_4X
	elif index == 3: # 8×
		get_viewport().msaa_3d = Viewport.MSAA_8X


## TAA 模式选择回调。
##
## 参数:
##   index: 0 为禁用，1 为启用
func _on_taa_option_button_item_selected(index: int) -> void:
	get_viewport().use_taa = index == 1


## 屏幕空间 AA 模式选择回调。
##
## 参数:
##   index: 对应 Viewport.ScreenSpaceAA 枚举值
func _on_screen_space_aa_option_button_item_selected(index: int) -> void:
	get_viewport().screen_space_aa = int(index) as Viewport.ScreenSpaceAA


## 全屏模式选择回调。
##
## 参数:
##   index: 窗口模式索引（窗口/全屏/独占全屏）
func _on_fullscreen_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1: # 全屏
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)
	elif index == 2: # 独占全屏
		get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)


## FOV 滑块值变化回调。
##
## 参数:
##   value: 视野角度值
func _on_fov_slider_value_changed(value: float) -> void:
	camera.fov = value

# 质量设置。

## 阴影大小选项选择回调。
##
## 参数:
##   index: 阴影分辨率级别（极低/很低/低/中/高/超高）
func _on_shadow_size_option_button_item_selected(index):
	if index == 0: # 最低
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		directional_light.shadow_bias = 0.06
		if is_compatibility:
			get_viewport().positional_shadow_atlas_size = 512
		else:
			get_viewport().positional_shadow_atlas_size = 0

	if index == 1: # 很低
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		directional_light.shadow_bias = 0.04
		get_viewport().positional_shadow_atlas_size = 1024
	if index == 2: # 低
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		directional_light.shadow_bias = 0.03
		get_viewport().positional_shadow_atlas_size = 2048
	if index == 3: # 中（默认）
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		directional_light.shadow_bias = 0.02
		get_viewport().positional_shadow_atlas_size = 4096
	if index == 4: # 高
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		directional_light.shadow_bias = 0.01
		get_viewport().positional_shadow_atlas_size = 8192
	if index == 5: # 超高
		RenderingServer.directional_shadow_atlas_set_size(16384, true)
		directional_light.shadow_bias = 0.005
		get_viewport().positional_shadow_atlas_size = 16384


## 阴影过滤选项选择回调。
##
## 参数:
##   index: 阴影过滤质量级别
func _on_shadow_filter_option_button_item_selected(index):
	if index == 0: # 很低
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	if index == 1: # 低
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	if index == 2: # 中（默认）
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	if index == 3: # 高
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	if index == 4: # 很高
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	if index == 5: # 超高
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


## 网格 LOD 选项选择回调。
##
## 参数:
##   index: LOD 阈值级别
func _on_mesh_lod_option_button_item_selected(index):
	if index == 0: # 很低
		get_viewport().mesh_lod_threshold = 8.0
	if index == 0: # 低
		get_viewport().mesh_lod_threshold = 4.0
	if index == 1: # 中
		get_viewport().mesh_lod_threshold = 2.0
	if index == 2: # 高（默认）
		get_viewport().mesh_lod_threshold = 1.0
	if index == 3: # 超高
		get_viewport().mesh_lod_threshold = 0.0

# 特效设置。

## SSR（屏幕空间反射）选项选择回调。
##
## 参数:
##   index: SSR 质量级别
func _on_ss_reflections_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.set_ssr_enabled(false)
	elif index == 1: # 低
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(8)
	elif index == 2: # 中
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(32)
	elif index == 3: # 高
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(56)


## SSAO（屏幕空间环境光遮蔽）选项选择回调。
##
## 参数:
##   index: SSAO 质量级别
func _on_ssao_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.ssao_enabled = false
	if index == 1: # 很低
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 2: # 低
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
	if index == 3: # 中
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if index == 4: # 高
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	if index == 5: # 超高
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.5, 2, 50, 300)


## SSIL（屏幕空间间接光照）选项选择回调。
##
## 参数:
##   index: SSIL 质量级别
func _on_ssil_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.ssil_enabled = false
	if index == 1: # 很低
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
	if index == 2: # 低
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
	if index == 3: # 中
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
	if index == 4: # 高
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
	if index == 5: # 超高
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)


## SDFGI 选项选择回调。
##
## 参数:
##   index: SDFGI 质量级别
func _on_sdfgi_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.sdfgi_enabled = false
	if index == 1: # 低
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(true)
	if index == 2: # 高
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(false)


## 辉光选项选择回调。
##
## 参数:
##   index: 辉光质量级别
func _on_glow_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.glow_enabled = false
	if index == 1: # 低
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(false)
	if index == 2: # 高
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(true)


## 体积雾选项选择回调。
##
## 参数:
##   index: 体积雾质量级别
func _on_volumetric_fog_option_button_item_selected(index: int) -> void:
	if index == 0: # 禁用（默认）
		world_environment.environment.volumetric_fog_enabled = false
	if index == 1: # 低
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(false)
	if index == 2: # 高
		world_environment.environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(true)

# 画面调节设置。

## 亮度滑块值变化回调。
##
## 参数:
##   value: 亮度值（范围 0.5~4）
func _on_brightness_slider_value_changed(value: float) -> void:
	world_environment.environment.set_adjustment_brightness(value)


## 对比度滑块值变化回调。
##
## 参数:
##   value: 对比度值（范围 0.5~4）
func _on_contrast_slider_value_changed(value: float) -> void:
	world_environment.environment.set_adjustment_contrast(value)


## 饱和度滑块值变化回调。
##
## 参数:
##   value: 饱和度值（范围 0.5~10）
func _on_saturation_slider_value_changed(value: float) -> void:
	world_environment.environment.set_adjustment_saturation(value)

# 质量预设。

## 极低预设按钮回调。
func _on_very_low_preset_pressed() -> void:
	%TAAOptionButton.selected = 0
	%MSAAOptionButton.selected = 0
	%ScreenSpaceAAOptionButton.selected = 0
	%ShadowSizeOptionButton.selected = 0
	%ShadowFilterOptionButton.selected = 0
	%MeshLODOptionButton.selected = 0
	%SDFGIOptionButton.selected = 0
	%GlowOptionButton.selected = 0
	%SSAOOptionButton.selected = 0
	%SSReflectionsOptionButton.selected = 0
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 0
	update_preset()

## 低预设按钮回调。
func _on_low_preset_pressed() -> void:
	%TAAOptionButton.selected = 0
	%MSAAOptionButton.selected = 0
	%ScreenSpaceAAOptionButton.selected = 1
	%ShadowSizeOptionButton.selected = 1
	%ShadowFilterOptionButton.selected = 1
	%MeshLODOptionButton.selected = 1
	%SDFGIOptionButton.selected = 0
	%GlowOptionButton.selected = 0
	%SSAOOptionButton.selected = 0
	%SSReflectionsOptionButton.selected = 0
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 0
	update_preset()


## 中预设按钮回调。
func _on_medium_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 0
	%ScreenSpaceAAOptionButton.selected = 2
	%ShadowSizeOptionButton.selected = 2
	%ShadowFilterOptionButton.selected = 2
	%MeshLODOptionButton.selected = 1
	%SDFGIOptionButton.selected = 1
	%GlowOptionButton.selected = 1
	%SSAOOptionButton.selected = 1
	%SSReflectionsOptionButton.selected = 1
	%SSILOptionButton.selected = 0
	%VolumetricFogOptionButton.selected = 1
	update_preset()


## 高预设按钮回调。
func _on_high_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 0
	%ScreenSpaceAAOptionButton.selected = 2
	%ShadowSizeOptionButton.selected = 3
	%ShadowFilterOptionButton.selected = 3
	%MeshLODOptionButton.selected = 2
	%SDFGIOptionButton.selected = 1
	%GlowOptionButton.selected = 2
	%SSAOOptionButton.selected = 2
	%SSReflectionsOptionButton.selected = 2
	%SSILOptionButton.selected = 2
	%VolumetricFogOptionButton.selected = 2
	update_preset()


## 超高预设按钮回调。
func _on_ultra_preset_pressed() -> void:
	%TAAOptionButton.selected = 1
	%MSAAOptionButton.selected = 1
	%ScreenSpaceAAOptionButton.selected = 2
	%ShadowSizeOptionButton.selected = 4
	%ShadowFilterOptionButton.selected = 4
	%MeshLODOptionButton.selected = 3
	%SDFGIOptionButton.selected = 2
	%GlowOptionButton.selected = 2
	%SSAOOptionButton.selected = 3
	%SSReflectionsOptionButton.selected = 3
	%SSILOptionButton.selected = 3
	%VolumetricFogOptionButton.selected = 2
	update_preset()


## 更新预设：模拟手动选择各选项以触发对应的更新代码。
func update_preset() -> void:
	%TAAOptionButton.item_selected.emit(%TAAOptionButton.selected)
	%MSAAOptionButton.item_selected.emit(%MSAAOptionButton.selected)
	%ScreenSpaceAAOptionButton.item_selected.emit(%ScreenSpaceAAOptionButton.selected)
	%ShadowSizeOptionButton.item_selected.emit(%ShadowSizeOptionButton.selected)
	%ShadowFilterOptionButton.item_selected.emit(%ShadowFilterOptionButton.selected)
	%MeshLODOptionButton.item_selected.emit(%MeshLODOptionButton.selected)
	%SDFGIOptionButton.item_selected.emit(%SDFGIOptionButton.selected)
	%GlowOptionButton.item_selected.emit(%GlowOptionButton.selected)
	%SSAOOptionButton.item_selected.emit(%SSAOOptionButton.selected)
	%SSReflectionsOptionButton.item_selected.emit(%SSReflectionsOptionButton.selected)
	%SSILOptionButton.item_selected.emit(%SSILOptionButton.selected)
	%VolumetricFogOptionButton.item_selected.emit(%VolumetricFogOptionButton.selected)


## 将不支持的选项按钮标记为禁用状态。
##
## 参数:
##   button: 要标记的 OptionButton 节点
func mark_as_unsupported(button: OptionButton) -> void:
	button.disabled = true
	button.add_item("不支持")
	button.select(button.item_count - 1)
