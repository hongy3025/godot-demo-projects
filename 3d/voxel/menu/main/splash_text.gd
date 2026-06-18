## 启动画面文本动画 —— 使文本周期性缩放。
##
## 继承自 [Control]，使用正弦波实现文本的呼吸式缩放效果。
extends Control

## 累计时间。
var time := 0.0

## _process 入口。每帧更新缩放。
##
## 参数:
##   delta: 帧时间间隔
##
## 缩放公式：1 - |sin(time * 4)| / 4，产生周期性缩放效果。
func _process(delta: float) -> void:
	time += delta
	scale = Vector2.ONE * (1 - abs(sin(time * 4)) / 4)
