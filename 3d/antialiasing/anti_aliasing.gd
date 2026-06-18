## 抗锯齿演示场景的主控制器。
##
## 继承自 [Node]，管理多个测试场景的切换、摄像机控制和抗锯齿参数调节。
## 支持 MSAA、TAA、SSAA、FSR 等多种抗锯齿和渲染缩放技术的实时切换对比。
extends Node


## 鼠标旋转灵敏度。
const ROT_SPEED = 0.003
## 滚轮缩放速度。
const ZOOM_SPEED = 0.125
## 鼠标拖拽旋转所需的按键掩码（左键 | 右键 | 中键）。
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

## 当前测试场景的索引。
var tester_index := 0
## 摄像机 X 轴旋转角度（俯仰），需与 RotationX 节点同步。
var rot_x := -TAU / 16
## 摄像机 Y 轴旋转角度（偏航），需与 CameraHolder 节点同步。
var rot_y := TAU / 8
## 摄像机与目标的距离。
var camera_distance := 2.0

## 所有测试场景的父节点。
@onready var testers: Node3D = $Testers
## 摄像机支架，控制 Y 轴旋转和 Z 轴位置。
@onready var camera_holder: Node3D = $CameraHolder
## 摄像机 X 轴旋转节点。
@onready var rotation_x: Node3D = $CameraHolder/RotationX
## 实际渲染用的 Camera3D 节点。
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D
## 显示 FPS 的 Label。
@onready var fps_label: Label = $FPSLabel

## 是否为兼容渲染模式（gl_compatibility）。
var is_compatibility: bool = false


## _ready 入口。初始化摄像机位置、UI 和兼容模式适配。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		is_compatibility = true
		# 隐藏兼容模式下不支持的功能。
		$Antialiasing/ScreenSpaceAAContainer.visible = false
		$Antialiasing/TemporalAAContainer.visible = false

		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $DirectionalLight3D.duplicate()
		new_light.light_energy = 0.3
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)

	# 禁用垂直同步以解除帧率上限，方便在高配机器上对比性能。
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


## _unhandled_input 入口。处理键盘切换、鼠标滚轮缩放和拖拽旋转。
##
## 参数:
##   input_event: 输入事件对象
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if input_event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance -= ZOOM_SPEED
		if input_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance += ZOOM_SPEED
		camera_distance = clamp(camera_distance, 1.5, 6)

	if input_event is InputEventMouseMotion and input_event.button_mask & MAIN_BUTTONS:
		# 使用 `screen_relative` 使鼠标灵敏度不受视口分辨率影响。
		var relative_motion: Vector2 = input_event.screen_relative
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.57, 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


## _process 入口。每帧更新摄像机位置、FPS 显示和帧率颜色。
##
## 参数:
##   delta: 帧时间间隔
##
## 核心逻辑：
## 1. 平滑移动摄像机到当前测试场景的 Z 轴位置
## 2. 平滑缩放摄像机距离
## 3. 更新 FPS 文本
## 4. 根据帧率用渐变色为 FPS 着色
func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	# 假设 CameraHolder 的 X 和 Y 坐标已正确设置。
	var current_position := camera_holder.global_transform.origin.z
	var target_position := current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position, target_position, 3 * delta)
	camera.position.z = lerpf(camera.position.z, camera_distance, 10 * delta)
	fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	# 根据帧率为 FPS 计数器着色。
	# Gradient 资源存储在 FPSLabel 节点的 metadata 中（可在检查器中查看）。
	fps_label.modulate = fps_label.get_meta(&"gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))


## 切换到上一个测试场景。
func _on_previous_pressed() -> void:
	tester_index = max(0, tester_index - 1)
	update_gui()


## 切换到下一个测试场景。
func _on_next_pressed() -> void:
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


## 更新 UI 显示：测试名称、前后按钮状态。
func update_gui() -> void:
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


## MSAA 模式选择回调。
##
## 参数:
##   index: OptionButton 选中的索引，对应 Viewport.MSAA 枚举值
##
## MSAA（多重采样抗锯齿）：质量高但速度慢，无法平滑透明（alpha scissor）纹理的边缘。
func _on_msaa_item_selected(index: int) -> void:
	get_viewport().msaa_3d = index as Viewport.MSAA


## FPS 限制滑块值变化回调。
##
## 参数:
##   value: 目标帧率值
##
## 渲染帧率影响 TAA 的效果，高帧率让 TAA 更快收敛。
## 在高刷新率显示器上，TAA 的残影问题在高帧率下不那么明显。
func _on_fps_limit_scale_value_changed(value: float) -> void:
	$Antialiasing/FPSLimitContainer/Value.text = str(roundi(value)) if not is_zero_approx(value) else "∞"
	Engine.max_fps = roundi(value)


## 渲染缩放滑块值变化回调。
##
## 参数:
##   value: 渲染缩放比例
func _on_render_scale_value_changed(value: float) -> void:
	get_viewport().scaling_3d_scale = value
	$Antialiasing/RenderScaleContainer/Value.text = "%d%%" % (value * 100)
	# 更新视口分辨率文本。
	_on_viewport_size_changed()
	if not is_compatibility:
		# 仅在支持时显示该功能。
		# FSR 1.0 仅在渲染缩放低于 100% 时有效。
		$Antialiasing/FidelityFXFSR.visible = value < 1.0
		$Antialiasing/FSRSharpness.visible = get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR and value < 1.0


## AMD FidelityFX FSR 1.0 开关回调。
##
## 参数:
##   button_pressed: 按钮是否被按下
func _on_amd_fidelityfx_fsr1_toggled(button_pressed: bool) -> void:
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if button_pressed else Viewport.SCALING_3D_MODE_BILINEAR
	# FSR 1.0 仅在渲染缩放低于 100% 时有效。
	$Antialiasing/FSRSharpness.visible = button_pressed


## FSR 锐度选项选择回调。
##
## 参数:
##   index: 锐度索引，值越低越锐利
##
## FSR 锐度值越低，画面越锐利。
func _on_fsr_sharpness_item_selected(index: int) -> void:
	match index:
		0:
			get_viewport().fsr_sharpness = 2.0
		1:
			get_viewport().fsr_sharpness = 0.8
		2:
			get_viewport().fsr_sharpness = 0.4
		3:
			get_viewport().fsr_sharpness = 0.2
		4:
			get_viewport().fsr_sharpness = 0.0


## 视口尺寸变化回调。更新视口分辨率显示文本。
func _on_viewport_size_changed() -> void:
	$ViewportResolution.text = "视口分辨率: %d×%d" % [
			get_viewport().size.x * get_viewport().scaling_3d_scale,
			get_viewport().size.y * get_viewport().scaling_3d_scale,
		]


## 垂直同步模式选择回调。
##
## 参数:
##   index: 垂直同步模式索引
##
## 垂直同步锁定帧率并消除画面撕裂，但会增加输入延迟和帧率不足时的卡顿。
## 自适应 V-Sync 在帧率不足时自动禁用 V-Sync，减少卡顿和输入延迟，代价是可见的撕裂。
func _on_v_sync_item_selected(index: int) -> void:
	match index:
		0: # 禁用（默认）
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1: # 自适应
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2: # 启用
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


## TAA（时域抗锯齿）模式选择回调。
##
## 参数:
##   index: 0 为禁用，1 为启用
##
## TAA 可以平滑包括高光锯齿在内的所有锯齿，但可能引入残影和运动模糊。
## 性能开销适中。
func _on_taa_item_selected(index: int) -> void:
	get_viewport().use_taa = index == 1


## 屏幕空间抗锯齿模式选择回调。
##
## 参数:
##   index: 对应 Viewport.ScreenSpaceAA 枚举值
##
## 屏幕空间 AA 比 MSAA 快得多（且能处理 alpha scissor 边缘），
## 但会略微模糊整个场景渲染。
## SMAA 比 FXAA 更锐利、边缘覆盖更好，但速度较慢。
func _on_screen_space_aa_item_selected(index: int) -> void:
	get_viewport().screen_space_aa = int(index) as Viewport.ScreenSpaceAA
