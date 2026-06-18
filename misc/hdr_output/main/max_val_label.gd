## HDR 最大值标签 —— 实时显示窗口的 HDR 最大线性输出值。
##
## 继承自 [Label]，每帧更新文本为当前窗口的 output_max_linear_value。
extends Label


## _process 入口，每帧更新标签文本。
func _process(_delta: float) -> void:
	text = "%0.2f" % get_window().get_output_max_linear_value()
