## 频谱可视化 —— 实时显示音频频谱的柱状图。
##
## 继承自 [Node2D]，使用 [AudioEffectSpectrumAnalyzerInstance] 获取音频频谱数据，
## 通过 _draw() 绘制彩色柱状图，并带有倒影效果和动画平滑过渡。
extends Node2D

## 频谱柱数量。
const VU_COUNT = 16
## 最大分析频率（Hz）。
const FREQ_MAX = 11050.0

## 绘图区域宽度（像素）。
const WIDTH = 800
## 绘图区域高度（像素）。
const HEIGHT = 250
## 高度缩放倍数。
const HEIGHT_SCALE = 8.0
## 最小分贝值，用于归一化能量。
const MIN_DB = 60
## 动画平滑速度（0~1，值越小越平滑）。
const ANIMATION_SPEED = 0.1

## 频谱分析器实例，从音频总线获取。
var spectrum: AudioEffectSpectrumAnalyzerInstance
## 每根柱子的最小值数组，用于动画平滑。
var min_values: Array[float] = []
## 每根柱子的最大值数组，用于动画平滑。
var max_values: Array[float] = []

## 绘制频谱柱状图：包括主体和半透明倒影。
func _draw() -> void:
	@warning_ignore("integer_division")
	var w := WIDTH / VU_COUNT
	for i in VU_COUNT:
		var min_height = min_values[i]
		var max_height = max_values[i]
		# 使用 lerp 实现平滑动画过渡
		var height = lerp(min_height, max_height, ANIMATION_SPEED)

		# 绘制主体柱状条
		draw_rect(
				Rect2(w * i, HEIGHT - height, w - 2, height),
				Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6)
			)
		# 绘制柱状条顶部高光线
		draw_line(
				Vector2(w * i, HEIGHT - height),
				Vector2(w * i + w - 2, HEIGHT - height),
				Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0),
				2.0,
				true
			)

		# 绘制柱状条的倒影（低透明度）
		draw_rect(
				Rect2(w * i, HEIGHT, w - 2, height),
				Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6) * Color(1, 1, 1, 0.125)
			)
		draw_line(
				Vector2(w * i, HEIGHT + height),
				Vector2(w * i + w - 2, HEIGHT + height),
				Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0) * Color(1, 1, 1, 0.125),
				2.0,
				true
			)


## 每帧更新频谱数据并触发重绘。
func _process(_delta: float) -> void:
	var data: Array[float] = []
	var prev_hz := 0.0

	# 将频率范围均分，计算每个频段的能量
	for i in range(1, VU_COUNT + 1):
		var hz := i * FREQ_MAX / VU_COUNT
		var magnitude := spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height := energy * HEIGHT * HEIGHT_SCALE
		data.append(height)
		prev_hz = hz

	# 更新每根柱子的最大值和最小值，实现平滑动画
	for i in VU_COUNT:
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerpf(max_values[i], data[i], ANIMATION_SPEED)

		if data[i] <= 0.0:
			min_values[i] = lerpf(min_values[i], 0.0, ANIMATION_SPEED)

	# 音频持续播放，因此每帧都需要重绘
	queue_redraw()


## 初始化：获取频谱分析器实例并初始化数据数组。
func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)
