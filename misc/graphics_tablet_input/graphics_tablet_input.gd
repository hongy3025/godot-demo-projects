## 数位板输入演示 —— 支持压感和倾斜的绘图应用。
##
## 继承自 [Control]，使用 Line2D 绘制笔迹，支持压感调节线宽、
## 倾斜向量显示、MSAA 抗锯齿、FPS 限制和垂直同步设置。
extends Control

# 自动分割长线条以避免性能问题
# 分割点数量限制（尤其是宽度曲线需要在每个新点上重建）
const SPLIT_POINT_COUNT = 1024

## 当前笔画
var stroke: Line2D
## 宽度曲线（用于压感控制）
var width_curve: Curve
## 压力值数组
var pressures := PackedFloat32Array()
## 事件位置
var event_position: Vector2
## 事件倾斜
var event_tilt: Vector2

## 线条颜色
var line_color := Color.BLACK
## 线条宽度
var line_width: float = 3.0

## 是否启用压感控制线宽
## 通过持续重建宽度曲线来匹配实际线条轮廓
var pressure_sensitive: bool = true

## 是否显示倾斜向量
var show_tilt_vector: bool = true

@onready var tablet_info: Label = %TabletInfo


## _ready 入口，禁用输入累积以获取精确的笔位置。
func _ready() -> void:
	# 禁用输入累积使数位板和鼠标输入尽可能频繁地报告
	# 禁用后可以在每个输入事件中查询笔/鼠标位置，不受帧率限制
	# 缺点是消耗更多 CPU 资源，仅在需要精确输入坐标时禁用
	Input.use_accumulated_input = false
	start_stroke()
	%TabletDriver.text = "Tablet driver: %s" % DisplayServer.tablet_get_current_driver()


## _input 入口，处理数位板输入事件。
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey:
		if Input.is_action_pressed(&"increase_line_width"):
			$CanvasLayer/PanelContainer/Options/LineWidth/HSlider.value += 0.5
		if Input.is_action_pressed(&"decrease_line_width"):
			$CanvasLayer/PanelContainer/Options/LineWidth/HSlider.value -= 0.5

	if not stroke:
		return

	if input_event is InputEventMouseMotion:
		var event_mouse_motion := input_event as InputEventMouseMotion
		tablet_info.text = "Pressure: %.3f\nTilt: %.3v\nInverted pen: %s" % [
				event_mouse_motion.pressure,
				event_mouse_motion.tilt,
				"Yes" if event_mouse_motion.pen_inverted else "No",
			]

		if event_mouse_motion.pressure <= 0 and stroke.points.size() > 1:
			# 笔触初始部分；创建新线条
			start_stroke()
			# 启用之前禁用的按钮
			%ClearAllLines.disabled = false
			%UndoLastLine.disabled = false

		if event_mouse_motion.pressure > 0:
			# 继续现有线条
			stroke.add_point(event_mouse_motion.position)
			pressures.push_back(event_mouse_motion.pressure)
			# 仅在启用压感时计算宽度曲线
			if width_curve:
				width_curve.clear_points()
				for pressure_idx in range(pressures.size()):
					width_curve.add_point(Vector2(
							float(pressure_idx) / pressures.size(),
							pressures[pressure_idx]
						))

			# 线条过长时分割为新线条以避免性能问题
			# 禁用输入累积时更容易达到此限制
			if stroke.get_point_count() >= SPLIT_POINT_COUNT:
				start_stroke()

		event_position = event_mouse_motion.position
		event_tilt = event_mouse_motion.tilt
		queue_redraw()


## _draw 入口，绘制倾斜向量指示线。
func _draw() -> void:
	if show_tilt_vector:
		# 绘制倾斜向量
		draw_line(event_position, event_position + event_tilt * 50, Color(1, 0, 0, 0.5), 2, true)


## 开始新的笔画。
func start_stroke() -> void:
	var new_stroke := Line2D.new()
	new_stroke.begin_cap_mode = Line2D.LINE_CAP_ROUND
	new_stroke.end_cap_mode = Line2D.LINE_CAP_ROUND
	new_stroke.joint_mode = Line2D.LINE_JOINT_ROUND
	# 根据线宽调整圆角精度以提升性能
	new_stroke.round_precision = mini(line_width, 8)
	new_stroke.default_color = line_color
	new_stroke.width = line_width
	if pressure_sensitive:
		new_stroke.width_curve = Curve.new()
	add_child(new_stroke)

	new_stroke.owner = self
	stroke = new_stroke
	if pressure_sensitive:
		width_curve = new_stroke.width_curve
	else:
		width_curve = null
	pressures.clear()


## 撤销上一笔画按钮回调。
func _on_undo_last_line_pressed() -> void:
	# 移除场景中最后一个 Line2D 节点
	var last_line_2d: Line2D = find_children("", "Line2D")[-1]
	if last_line_2d:
		# 移除末尾的空线条（由鼠标移动产生）
		# 一次操作不一定足够，列表末尾可能有多个空行
		if last_line_2d.get_point_count() == 0:
			last_line_2d.queue_free()

			var other_last_line_2d: Line2D = find_children("", "Line2D")[-2]
			if other_last_line_2d:
				other_last_line_2d.queue_free()
		else:
			last_line_2d.queue_free()

		# 鼠标移动时会立即创建新线条，所以列表为空时最多有 2 项
		%UndoLastLine.disabled = find_children("", "Line2D").size() <= 2
		start_stroke()


## 清除所有线条按钮回调。
func _on_clear_all_lines_pressed() -> void:
	# 移除场景中所有 Line2D 节点
	for node in find_children("", "Line2D"):
		node.queue_free()

	%ClearAllLines.disabled = true
	start_stroke()


## 线条颜色选择回调。
func _on_line_color_changed(color: Color) -> void:
	line_color = color
	# 立即生效
	start_stroke()


## 线条宽度值变化回调。
func _on_line_width_value_changed(value: float) -> void:
	line_width = value
	$CanvasLayer/PanelContainer/Options/LineWidth/Value.text = "%.1f" % value
	# 立即生效
	start_stroke()


## 压感开关切换回调。
func _on_pressure_sensitive_toggled(toggled_on: bool) -> void:
	pressure_sensitive = toggled_on
	# 立即生效
	start_stroke()


## 倾斜向量显示开关切换回调。
func _on_show_tilt_vector_toggled(toggled_on: bool) -> void:
	show_tilt_vector = toggled_on


## MSAA 选项选择回调。
func _on_msaa_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA


## 最大 FPS 值变化回调。
func _on_max_fps_value_changed(value: float) -> void:
	# 项目启用了低处理器使用模式，因此修改休眠间隔
	# 这是帧间微秒值，需要从 FPS 值转换
	@warning_ignore("narrowing_conversion")
	OS.low_processor_usage_mode_sleep_usec = 1_000_000.0 / value
	$CanvasLayer/PanelContainer/Options/MaxFPS/Value.text = str(roundi(value))


## 垂直同步切换回调。
func _on_v_sync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)


## 输入累积切换回调。
func _on_input_accumulation_toggled(toggled_on: bool) -> void:
	Input.use_accumulated_input = toggled_on
