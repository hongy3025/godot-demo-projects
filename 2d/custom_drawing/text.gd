## 文本绘制演示 —— 使用 _draw() 方法绘制字符和字符串。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false


func _draw() -> void:
	var font := get_theme_default_font()
	const FONT_SIZE = 24
	const STRING = "Hello world!"
	var margin := Vector2(240, 60)

	var offset := Vector2()
	var advance := Vector2()
	for character in STRING:
		# 用随机柔和颜色绘制每个字符
		# 注意上一轮循环计算的 advance 用作偏移
		draw_char(font, margin + offset + advance, character, FONT_SIZE, Color.from_hsv(randf(), 0.4, 1.0))

		# 获取刚绘制的字符的字形索引，用于计算字形间距
		var glyph_idx := TextServerManager.get_primary_interface().font_get_glyph_index(
				get_theme_default_font().get_rids()[0],
				FONT_SIZE,
				character.unicode_at(0),
				0
			)
		advance.x += TextServerManager.get_primary_interface().font_get_glyph_advance(
				get_theme_default_font().get_rids()[0],
				FONT_SIZE,
				glyph_idx
			).x

	offset += Vector2(0, 32)
	# 绘制字体轮廓时，必须在主文本之前绘制，使轮廓出现在主文本后方
	draw_string_outline(
			font,
			margin + offset,
			STRING,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_SIZE,
			12,
			Color.ORANGE.darkened(0.6)
		)
	# 使用 draw_multiline_string() 可绘制含换行符或自动换行的字符串。
	# 宽度为 -1 表示"无限制"。
	draw_string(
			font,
			margin + offset,
			STRING,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			FONT_SIZE,
			Color.YELLOW
		)
