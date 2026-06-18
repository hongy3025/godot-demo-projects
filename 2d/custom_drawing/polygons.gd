## 多边形与折线绘制演示 —— 使用 _draw() 方法绘制各种多边形和线条。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false


func _draw() -> void:
	var margin := Vector2(240, 40)

	var line_width_thin := 0.5 if use_antialiasing else -1.0

	var antialiasing_width_offset := 1.0 if use_antialiasing else 0.0

	var points := PackedVector2Array([
			Vector2(0, 0),
			Vector2(0, 60),
			Vector2(60, 90),
			Vector2(60, 0),
			Vector2(40, 25),
			Vector2(10, 40),
		])
	var colors := PackedColorArray([
			Color.WHITE,
			Color.RED,
			Color.GREEN,
			Color.BLUE,
			Color.MAGENTA,
			Color.MAGENTA,
		])

	var offset := Vector2()
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 1), colors.slice(0, 1), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 2), colors.slice(0, 2), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 3), colors.slice(0, 3), PackedVector2Array())

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_primitive(points.slice(0, 4), colors.slice(0, 4), PackedVector2Array())

	# 绘制多色多边形，颜色在点之间插值
	offset = Vector2(0, 120)
	draw_set_transform(margin + offset)
	draw_polygon(points, colors)

	# 绘制单色多边形
	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_colored_polygon(points, Color.YELLOW)

	# 绘制基于多边形的线条，每段相连，draw_polyline() 始终绘制连续线条
	offset = Vector2(0, 240)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline(points, Color.SKY_BLUE, 6.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_polyline_colors(points, colors, 6.0 - antialiasing_width_offset, use_antialiasing)

	# 在单个绘制命令中绘制多条线。与 draw_polyline() 不同，线条之间不连续。
	# 比多次调用 draw_line() 更快，适合同时绘制数十条以上线条。
	offset = Vector2(0, 360)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline(points, Color.SKY_BLUE, 6.0 - antialiasing_width_offset, use_antialiasing)

	# draw_multiline_colors() 可在单个绘制命令中绘制不同颜色的线条
	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), line_width_thin, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), 2.0 - antialiasing_width_offset, use_antialiasing)

	offset += Vector2(90, 0)
	draw_set_transform(margin + offset)
	draw_multiline_colors(points, colors.slice(0, 3), 6.0 - antialiasing_width_offset, use_antialiasing)
