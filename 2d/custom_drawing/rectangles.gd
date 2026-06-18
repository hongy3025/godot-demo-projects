## 矩形与样式盒绘制演示 —— 使用 _draw() 方法绘制各种矩形和样式盒。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false


func _draw() -> void:
	var margin := Vector2(200, 40)

	var line_width_thin := 0.5 if use_antialiasing else -1.0

	var antialiasing_width_offset := 1.0 if use_antialiasing else 0.0

	var offset := Vector2()
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			line_width_thin,
			use_antialiasing
		)

	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			2.0 - antialiasing_width_offset,
			use_antialiasing
		)

	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)),
			Color.PURPLE,
			false,
			6.0 - antialiasing_width_offset,
			use_antialiasing
		)

	# 绘制实心矩形，宽度参数被忽略
	offset += Vector2(120, 0)
	draw_rect(
			Rect2(margin + offset, Vector2(100, 50)).grow(-antialiasing_width_offset * 0.5),
			Color.PURPLE,
			true,
			-1.0,
			use_antialiasing
		)

	# 使用 draw_set_transform() 旋转矩形
	offset += Vector2(170, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			line_width_thin,
			use_antialiasing
		)
	offset += Vector2(120, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			2.0 - antialiasing_width_offset,
			use_antialiasing
		)
	offset += Vector2(120, 0)
	draw_set_transform(margin + offset, deg_to_rad(22.5))
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			6.0 - antialiasing_width_offset,
			use_antialiasing
		)

	# draw_set_transform_matrix() 是 draw_set_transform() 的高级版本，
	# 可应用 draw_set_transform() 不支持的变换（如倾斜）
	offset = Vector2(20, 60)
	var custom_transform := get_transform().translated(margin + offset)
	custom_transform.y.x -= 0.5
	draw_set_transform_matrix(custom_transform)
	draw_rect(
			Rect2(Vector2(), Vector2(100, 50)),
			Color.PURPLE,
			false,
			6.0 - antialiasing_width_offset,
			use_antialiasing
		)
	draw_set_transform(Vector2())

	# 绘制 StyleBoxFlat 样式盒
	offset = Vector2(0, 250)
	var style_box_flat := StyleBoxFlat.new()
	style_box_flat.set_border_width_all(4)
	style_box_flat.set_corner_radius_all(8)
	style_box_flat.shadow_size = 1
	style_box_flat.shadow_offset = Vector2(4, 4)
	style_box_flat.shadow_color = Color.RED
	style_box_flat.anti_aliasing = use_antialiasing
	draw_style_box(style_box_flat, Rect2(margin + offset, Vector2(100, 50)))

	offset += Vector2(130, 0)
	var style_box_flat_2 := StyleBoxFlat.new()
	style_box_flat_2.draw_center = false
	style_box_flat_2.set_border_width_all(4)
	style_box_flat_2.set_corner_radius_all(8)
	style_box_flat_2.corner_detail = 1
	style_box_flat_2.border_color = Color.GREEN
	style_box_flat_2.anti_aliasing = use_antialiasing
	draw_style_box(style_box_flat_2, Rect2(margin + offset, Vector2(100, 50)))

	offset += Vector2(160, 0)
	var style_box_flat_3 := StyleBoxFlat.new()
	style_box_flat_3.draw_center = false
	style_box_flat_3.set_border_width_all(4)
	style_box_flat_3.set_corner_radius_all(8)
	style_box_flat_3.border_color = Color.CYAN
	style_box_flat_3.shadow_size = 40
	style_box_flat_3.shadow_offset = Vector2()
	style_box_flat_3.shadow_color = Color.CORNFLOWER_BLUE
	style_box_flat_3.anti_aliasing = use_antialiasing
	custom_transform = get_transform().translated(margin + offset)
	custom_transform.x.y -= 0.5
	draw_set_transform_matrix(custom_transform)
	draw_style_box(style_box_flat_3, Rect2(Vector2(), Vector2(100, 50)))

	draw_set_transform(Vector2())
