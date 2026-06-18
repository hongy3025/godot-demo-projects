## 动画绘制演示 —— 使用 _draw() 方法创建动态圆弧动画。
## @tool 脚本使自定义 2D 绘制在编辑器中可见。
@tool
extends Panel

## 是否启用抗锯齿。
var use_antialiasing: bool = false

## 时间累积变量，用于驱动动画进度。
var time := 0.0

func _process(delta: float) -> void:
	# 累加时间计数器，用于 _draw() 中的动画
	time += delta
	# 每帧强制重绘，使动画可见。
	# 仅在节点可见时执行，避免不必要的持续重绘。
	if is_visible_in_tree():
		queue_redraw()


func _draw() -> void:
	var margin := Vector2(240, 70)
	var offset := Vector2()

	# 线宽为 -1.0 仅在禁用抗锯齿时可用，使用硬件线条绘制
	var line_width_thin := 0.5 if use_antialiasing else -1.0

	# 绘制动画圆弧，模拟圆形进度条。
	# 起始角度设置为从顶部开始。
	const POINT_COUNT = 48
	var progress := wrapf(time, 0.0, 1.0)
	draw_arc(
			margin + offset,
			50.0,
			0.75 * TAU,
			(0.75 + progress) * TAU,
			POINT_COUNT,
			Color.MEDIUM_AQUAMARINE,
			line_width_thin,
			use_antialiasing
		)
