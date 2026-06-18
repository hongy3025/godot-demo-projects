## 滑块值标签 —— 实时显示关联滑块的值。
@tool
extends Label


func _process(_delta: float) -> void:
	var slider: HSlider = get_node(^"../HSlider")
	text = "%.1f" % slider.value
