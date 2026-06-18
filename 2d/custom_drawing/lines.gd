## 线条与圆形绘制演示 —— 使用 _draw() 方法绘制各种线条、圆形和弧线。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false


func _draw() -> void:
	var margin := Vector2(200, 50)

	# 线宽为 -1.0 仅在禁用抗锯齿时可用，此时使用硬件线条绘制而非多边形线条绘制。
	# 需要时自动使用多边形线条绘制以避免运行时警告。
	# 使用 0.5 而非 1.0 的线宽以更好地匹配非抗锯齿线条的外观。
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	# 启用抗锯齿时，粗线条减薄 1 像素以补偿抗锯齿导致的视觉增粗
	var antialiasing_width_offset := 1.0 if use_antialiasing else 0.0

	var offset := Vector2()
	var line_length := Vector2(140, 35)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, line_width_thin, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 2.0 - antialiasing_width_offset, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_line(margin + offset, margin + offset + line_length, Color.GREEN, 6.0 - antialiasing_width_offset, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, line_width_thin, 5.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 2.0 - antialiasing_width_offset, 10.0, true, use_antialiasing)
	offset += Vector2(line_length.x + 15, 0)
	draw_dashed_line(margin + offset, margin + offset + line_length, Color.CYAN, 6.0 - antialiasing_width_offset, 15.0, true, use_antialiasing)


	offset = Vector2(40, 120)
	draw_circle(margin + offset, 40, Color.ORANGE, false, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40, Color.ORANGE, false, 6.0 - antialiasing_width_offset, use_antialiasing)

	# 绘制实心圆，宽度参数被忽略（设为 -1.0 以避免警告）
	# 半径减去抗锯齿宽度偏移的一半以补偿视觉增粗
	offset += Vector2(100, 0)
	draw_circle(margin + offset, 40 - antialiasing_width_offset * 0.5, Color.ORANGE, true, -1.0, use_antialiasing)

	# 绘制水平拉伸的圆形
	offset += Vector2(200, 0)
	draw_set_transform(margin + offset, 0.0, Vector2(3.0, 1.0))
	draw_circle(Vector2(), 40, Color.ORANGE, false, line_width_thin, use_antialiasing)
	draw_set_transform(Vector2())

	# 绘制四分之一圆弧（TAU 表示一周的弧度）
	const POINT_COUNT_HIGH = 24
	offset = Vector2(0, 200)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 60, 0, 0.25 * TAU, POINT_COUNT_HIGH, Color.YELLOW, 6.0 - antialiasing_width_offset, use_antialiasing)

	# 使用低点数绘制四分之三圆弧，呈现有棱角的外观
	const POINT_COUNT_LOW = 7
	offset += Vector2(125, 30)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, line_width_thin, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(100, 0)
	draw_arc(margin + offset, 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, 6.0 - antialiasing_width_offset, use_antialiasing)

	# 绘制水平拉伸的弧线
	offset += Vector2(200, 0)
	draw_set_transform(margin + offset, 0.0, Vector2(3.0, 1.0))
	draw_arc(Vector2(), 40, -0.25 * TAU, 0.5 * TAU, POINT_COUNT_LOW, Color.YELLOW, line_width_thin, use_antialiasing)
	draw_set_transform(Vector2())
