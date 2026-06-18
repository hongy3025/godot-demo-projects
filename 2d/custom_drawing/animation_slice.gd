## 动画切片绘制演示 —— 使用 draw_animation_slice() 创建逐帧动画。
## 每帧在随机位置和颜色下绘制矩形，通过时间切片控制可见性。
extends Control

## 是否启用抗锯齿。
var use_antialiasing: bool = false


func _draw() -> void:
	var margin := Vector2(240, 70)
	var offset := Vector2(0, 150)
	# 使用绘制命令创建动画的示例。
	# 对于"连续"动画，可在 _draw() 中使用计时器，并在 _process() 中调用 queue_redraw() 每帧重绘。
	# 动画时长（秒）。动画将在指定时长后循环。
	const ANIMATION_LENGTH = 2.0
	# 每秒 5 帧，共 10 帧
	const ANIMATION_FRAMES = 10

	# 为每帧声明随机旋转和颜色。
	# draw_animation_slice() 使后续绘制命令仅在当前时间处于切片范围内时可见。
	# 注意：暂停不影响 draw_animation_slice() 绘制的动画（会继续播放）。
	for frame in ANIMATION_FRAMES:
		# remap() 用于确定帧可见的时间切片。
		# 例如第 2 帧的 slice_begin 为 0.2，slice_end 为 0.4。
		var slice_begin := remap(frame, 0, ANIMATION_FRAMES, 0, ANIMATION_LENGTH)
		var slice_end := remap(frame + 1, 0, ANIMATION_FRAMES, 0, ANIMATION_LENGTH)
		draw_animation_slice(ANIMATION_LENGTH, slice_begin, slice_end)
		draw_set_transform(margin + offset, deg_to_rad(randf_range(-5.0, 5.0)))
		draw_rect(
				Rect2(Vector2(), Vector2(100, 50)),
				Color.from_hsv(randf(), 0.4, 1.0),
				true,
				-1.0,
				use_antialiasing
			)

	draw_end_animation()
