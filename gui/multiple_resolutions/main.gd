## 多分辨率演示 —— 展示 Godot 的多分辨率适配方案。
## 继承自 [Control]，根节点 "Main" 和 AspectRatioContainer 是此演示的核心。
## 两个节点的 Layout 都设置为 Full Rect（锚点铺满整个视口）。
## 演示如何根据窗口大小变化动态调整 UI 布局和宽高比。
extends Control

## 基础窗口大小，从项目设置中读取视口宽高。
var base_window_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

# 以下默认值与此演示的项目设置匹配。在自己的项目中请根据需要调整。
## 窗口拉伸模式，默认使用 Canvas Items 模式。
var stretch_mode := Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
## 窗口拉伸宽高比，默认使用 Expand（扩展）模式。
var stretch_aspect := Window.CONTENT_SCALE_ASPECT_EXPAND

## 缩放因子。
var scale_factor := 1.0
## GUI 宽高比，-1 表示自适应窗口。
var gui_aspect_ratio := -1.0
## GUI 边距。
var gui_margin := 0.0

## 面板节点引用。
@onready var panel: Panel = $Panel
## 宽高比容器节点引用。
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer


## _ready 入口：连接窗口大小变化信号并延迟更新容器。
## `resized` 信号在窗口大小变化时触发，因为根 Control 节点使用 Full Rect 锚点，
## 其大小始终等于窗口大小。
func _ready() -> void:
	resized.connect(_on_resized)
	update_container.call_deferred()


## 更新容器布局。根据当前 GUI 宽高比设置 AspectRatioContainer 的比例和面板偏移。
## 此函数需要延迟执行以解决容器更新延迟一帧的问题。
## 否则 `panel.size` 返回的是上一帧的值，导致 "Fit to Window" 设置下内部
## AspectRatioContainer 的尺寸计算不正确。
func update_container() -> void:
	for _i in 2:
		if is_equal_approx(gui_aspect_ratio, -1.0):
			# 自适应窗口模式：让 AspectRatioContainer 使用与窗口相同的宽高比，
			# 使其不产生任何可见效果。
			arc.ratio = panel.size.aspect()
			# 在 AspectRatioContainer 的父节点（Panel）上应用 GUI 偏移。
			# 这样偏移也会影响位于 AspectRatioContainer 外部的控件（如此演示中的内侧标签）。
			panel.offset_top = gui_margin
			panel.offset_bottom = -gui_margin
		else:
			# 固定宽高比模式。
			arc.ratio = min(panel.size.aspect(), gui_aspect_ratio)
			# 根据宽高比调整上下偏移，确保 GUI 偏移设置的行为与窗口具有原始宽高比时一致。
			panel.offset_top = gui_margin / gui_aspect_ratio
			panel.offset_bottom = -gui_margin / gui_aspect_ratio

		panel.offset_left = gui_margin
		panel.offset_right = -gui_margin


## GUI 宽高比选项下拉框回调。
## 参数 index: 选项索引，0=自适应窗口，1-6=预设宽高比。
func _on_gui_aspect_ratio_item_selected(index: int) -> void:
	match index:
		0:  # Fit to Window
			gui_aspect_ratio = -1.0
		1:  # 5:4
			gui_aspect_ratio = 5.0 / 4.0
		2:  # 4:3
			gui_aspect_ratio = 4.0 / 3.0
		3:  # 3:2
			gui_aspect_ratio = 3.0 / 2.0
		4:  # 16:10
			gui_aspect_ratio = 16.0 / 10.0
		5:  # 16:9
			gui_aspect_ratio = 16.0 / 9.0
		6:  # 21:9
			gui_aspect_ratio = 21.0 / 9.0

	update_container.call_deferred()


## 窗口大小变化回调：延迟更新容器布局。
func _on_resized() -> void:
	update_container.call_deferred()


## GUI 边距滑块拖动结束回调：更新边距值并刷新容器。
func _on_gui_margin_drag_ended(_value_changed: bool) -> void:
	gui_margin = $"Panel/AspectRatioContainer/Panel/CenterContainer/Options/GUIMargin/HSlider".value
	$"Panel/AspectRatioContainer/Panel/CenterContainer/Options/GUIMargin/Value".text = str(gui_margin)
	update_container.call_deferred()


## 窗口基础大小选项下拉框回调：设置窗口的基础分辨率。
## 参数 index: 选项索引，对应不同的分辨率预设。
func _on_window_base_size_item_selected(index: int) -> void:
	match index:
		0:  # 648×648 (1:1)
			base_window_size = Vector2(648, 648)
		1:  # 640×480 (4:3)
			base_window_size = Vector2(640, 480)
		2:  # 720×480 (3:2)
			base_window_size = Vector2(720, 480)
		3:  # 800×600 (4:3)
			base_window_size = Vector2(800, 600)
		4:  # 1152×648 (16:9)
			base_window_size = Vector2(1152, 648)
		5:  # 1280×720 (16:9)
			base_window_size = Vector2(1280, 720)
		6:  # 1280×800 (16:10)
			base_window_size = Vector2(1280, 800)
		7:  # 1680×720 (21:9)
			base_window_size = Vector2(1680, 720)

	get_window().content_scale_size = base_window_size
	update_container.call_deferred()


## 窗口拉伸模式选项下拉框回调：设置窗口的内容缩放模式。
## 当模式为 Disabled 时，禁用基础大小和宽高比选项。
func _on_window_stretch_mode_item_selected(index: int) -> void:
	stretch_mode = index as Window.ContentScaleMode
	get_window().content_scale_mode = stretch_mode

	# 当拉伸模式为 Disabled 时，禁用不相关的选项。
	$"Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowBaseSize/OptionButton".disabled = stretch_mode == Window.CONTENT_SCALE_MODE_DISABLED
	$"Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowStretchAspect/OptionButton".disabled = stretch_mode == Window.CONTENT_SCALE_MODE_DISABLED


## 窗口拉伸宽高比选项下拉框回调：设置窗口的内容缩放宽高比。
func _on_window_stretch_aspect_item_selected(index: int) -> void:
	stretch_aspect = index as Window.ContentScaleAspect
	get_window().content_scale_aspect = stretch_aspect


## 窗口缩放因子滑块拖动结束回调：更新缩放因子并应用到窗口。
func _on_window_scale_factor_drag_ended(_value_changed: bool) -> void:
	scale_factor = $"Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowScaleFactor/HSlider".value
	$"Panel/AspectRatioContainer/Panel/CenterContainer/Options/WindowScaleFactor/Value".text = "%d%%" % (scale_factor * 100)
	get_window().content_scale_factor = scale_factor


## 窗口拉伸缩放模式选项下拉框回调：设置窗口的内容缩放拉伸模式。
func _on_window_stretch_scale_mode_item_selected(index: int) -> void:
	get_window().content_scale_stretch = index
