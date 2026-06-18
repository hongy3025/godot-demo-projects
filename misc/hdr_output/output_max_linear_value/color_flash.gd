## HDR 颜色闪光 —— 单个网格的 HDR 亮度闪光效果。
##
## 继承自 [MeshInstance3D]，被调用 flash() 后颜色亮度逐渐增强到 HDR 最大输出值，
## 然后按 fade_time 衰减回原始颜色。
extends MeshInstance3D

## 衰减时间（秒）
@export_range(0, 3, 0.05, "or_less", "or_greater") var fade_time: float = 1.0

## 原始基础颜色
var _base_color: Color
## 动画值 (0.0 ~ 1.0)
var _animation_value: float = 0.0


## 触发闪光效果。
func flash() -> void:
	_animation_value = 1.0


## _init 入口，获取原始基础颜色。
func _init() -> void:
	_base_color = (get_active_material(0) as StandardMaterial3D).albedo_color
	set_process(true)


## _process 入口，每帧更新颜色亮度。
func _process(delta: float) -> void:
	_animation_value -= delta / fade_time
	if _animation_value < 0.0:
		_animation_value = 0.0

	if _animation_value == 0.0:
		(get_active_material(0) as StandardMaterial3D).albedo_color = _base_color
	else:
		# 将颜色亮度调整到最亮，不受 SDR 或 HDR 输出限制
		# 但不超过 max_linear_value_limit
		var max_linear_value = get_window().get_output_max_linear_value()
		# 颜色必须使用线性编码才能进行数学运算
		var linear_color = _base_color.srgb_to_linear()
		var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
		var brightness_scale = lerpf(1.0, max_linear_value / max_rgb_value, _animation_value)
		linear_color *= brightness_scale
		# 恢复 alpha 通道，不应被修改
		linear_color.a = _base_color.a
		# 转换回非线性 sRGB 编码
		(get_active_material(0) as StandardMaterial3D).albedo_color = linear_color.linear_to_srgb()
