## 纹理绘制演示 —— 使用 _draw() 方法绘制各种纹理效果。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false

func _draw() -> void:
	const ICON = preload("res://icon.svg")
	var margin := Vector2(260, 40)

	var offset := Vector2()
	# 绘制纹理
	draw_texture(ICON, margin + offset, Color.WHITE)

	# draw_set_transform() 是有状态的命令：会影响其后所有 draw_ 方法。
	# 可用于平移、旋转或缩放没有专用参数的 draw_ 方法。
	# 要重置变换，调用 draw_set_transform(Vector2())。
	#
	# 绘制旋转并缩放到原始像素大小一半的纹理
	offset += Vector2(200, 20)
	draw_set_transform(margin + offset, deg_to_rad(45.0), Vector2(0.5, 0.5))
	draw_texture(ICON, Vector2(), Color.WHITE)
	draw_set_transform(Vector2())

	# 绘制拉伸的纹理。图标为 128×128，此处绘制为 2 倍大小
	offset += Vector2(70, -20)
	draw_texture_rect(
			ICON,
			Rect2(margin + offset, Vector2(256, 256)),
			false,
			Color.GREEN
		)


	# 绘制平铺纹理。图标为 128×128，此处每个轴绘制两次
	offset += Vector2(270, 0)
	draw_texture_rect(
			ICON,
			Rect2(margin + offset, Vector2(256, 256)),
			true,
			Color.GREEN
		)

	offset = Vector2(0, 300)

	# 绘制纹理区域（仅绘制纹理的一部分）
	draw_texture_rect_region(
			ICON,
			Rect2(margin + offset, Vector2(128, 128)),
			Rect2(Vector2(32, 32), Vector2(64, 64)),
			Color.VIOLET
		)

	# 从比原始纹理（128×128）更大的区域平铺绘制纹理。
	# transposing 启用时会逆时针旋转图像 90 度。
	# 要使平铺生效，CanvasItem 的 Repeat 属性必须在检查器中设置为 Enabled。
	offset += Vector2(140, 0)
	draw_texture_rect_region(
			ICON,
			Rect2(margin + offset, Vector2(128, 128)),
			Rect2(Vector2(), Vector2(512, 512)),
			Color.VIOLET,
			true
		)
