# Copyright (c) 2023 Patryk Kalinowski (patrykkalinowski.com)
# SPDX-License-Identifier: MIT

## 1€ 滤波器（One Euro Filter）实现 —— 用于平滑带噪的实时信号。
##
## 参考论文：https://gery.casiez.net/1euro/[br]
## 修改自：https://github.com/patrykkalinowski/godot-xr-kit/blob/master/addons/xr-kit/smooth-input-filter/scripts/one_euro_filter.gd
## 
## 核心思想：根据信号变化速度动态调整平滑系数。
## 信号变化慢时（噪声为主），加大平滑力度；信号变化快时（真实运动），减少平滑以降低延迟。
## 包含内部类 [LowPassFilter] 实现一阶低通滤波。
class_name OneEuroFilter

## 最小截止频率。值越小，静止时越平滑。
var min_cutoff: float
## 速度系数。值越大，快速变化时响应越快（延迟越低）。
var beta: float
## 导数信号的截止频率。
var d_cutoff: float
## 值信号的低通滤波器实例。
var x_filter: LowPassFilter
## 导数信号（变化速度）的低通滤波器实例。
var dx_filter: LowPassFilter

## 构造函数：初始化滤波器参数和两个低通滤波器实例。
## args: 包含 cutoff（最小截止频率）和 beta（速度系数）的字典
func _init(args: Variant) -> void:
	min_cutoff = args.cutoff
	beta = args.beta
	d_cutoff = args.cutoff
	x_filter = LowPassFilter.new()
	dx_filter = LowPassFilter.new()


## 计算低通滤波器的 alpha 系数。
## rate: 采样率（Hz）
## cutoff: 截止频率（Hz）
## 返回: alpha 值（0~1，越大响应越快）
func alpha(rate: float, cutoff: float) -> float:
	var tau: float = 1.0 / (2 * PI * cutoff)
	var te: float = 1.0 / rate

	return 1.0 / (1.0 + tau/te)


## 对输入值应用 1€ 滤波。
## value: 当前输入值
## delta: 时间间隔（秒）
## 返回: 滤波后的值
func filter(value: float, delta: float) -> float:
	# 计算采样率
	var rate: float = 1.0 / delta
	# 计算一阶导数（变化速度）
	var dx: float = (value - x_filter.last_value) * rate

	# 对导数进行低通滤波
	var edx: float = dx_filter.filter(dx, alpha(rate, d_cutoff))
	# 根据滤波后的导数动态调整截止频率：变化越快，截止频率越高（延迟越低）
	var cutoff: float = min_cutoff + beta * abs(edx)
	# 对原始值进行低通滤波
	return x_filter.filter(value, alpha(rate, cutoff))


## 一阶低通滤波器内部类。
class LowPassFilter:
	## 上一帧的滤波输出值。
	var last_value: float


	func _init() -> void:
		last_value = 0


	## 对输入值应用低通滤波。
	## value: 当前输入值
	## alpha: 平滑系数（0~1，越大响应越快）
	## 返回: 滤波后的值
	func filter(value: float, alpha: float) -> float:
		var result := alpha * value + (1 - alpha) * last_value
		last_value = result

		return result
