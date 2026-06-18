## HDR 自调制颜色适配器 —— 将 SDR 颜色映射到 HDR 输出范围。
##
## 继承自 [CanvasItem]，监听窗口的 output_max_linear_value_changed 信号，
## 自动调整 self_modulate 使 SDR 颜色在 HDR 显示器上正确显示。
extends CanvasItem

## SDR 颜色值（当 CanvasItem 的基色为白色时使用此颜色）
@export var sdr_self_modulate: Color = Color.WHITE

## 最大线性值限制（设为 -1.0 表示不限制）
@export_range(0, 20, 0.1, "or_less", "or_greater") var linear_limit: float = -1.0

## 为 true 时 linear_limit 表示最终颜色的最大亮度
## 为 false 时 linear_limit 表示最终颜色的最大颜色分量值
@export var use_luminance_for_limit: bool = true


## _enter_tree 入口，连接窗口的 HDR 输出变化信号。
func _enter_tree() -> void:
	var window: Window = get_window()
	window.output_max_linear_value_changed.connect(_on_output_max_linear_value_changed)
	_on_output_max_linear_value_changed(window.get_output_max_linear_value())


## _exit_tree 入口，断开信号连接。
func _exit_tree() -> void:
	get_window().output_max_linear_value_changed.disconnect(_on_output_max_linear_value_changed)


## HDR 输出最大值变化回调，重新计算 self_modulate。
func _on_output_max_linear_value_changed(output_max_linear_value: float) -> void:
	# 颜色必须使用线性编码才能进行数学运算
	var linear_color = sdr_self_modulate.srgb_to_linear()

	if linear_limit >= 0.0:
		if use_luminance_for_limit:
			# 先将颜色调整到屏幕能显示的最亮
			var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
			linear_color *= output_max_linear_value / max_rgb_value

			# 应用限制
			var original_luminance = linear_color.get_luminance()
			if original_luminance > linear_limit:
				linear_color *= linear_limit / original_luminance
		else:
			# 基于颜色分量值和屏幕能力的限制可以合并计算
			var limited_max_linear_value = minf(output_max_linear_value, linear_limit)
			var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
			linear_color *= limited_max_linear_value / max_rgb_value
	else:
		# 无限制；将颜色缩放到屏幕能显示的最亮
		var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
		linear_color *= output_max_linear_value / max_rgb_value

	# 恢复 alpha 通道，不应被修改
	linear_color.a = sdr_self_modulate.a

	# 转换回非线性 sRGB 编码
	self_modulate = linear_color.linear_to_srgb()
