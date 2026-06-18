## 时间缩放控制器。
extends HBoxContainer


func _on_h_slider_value_changed(value: float) -> void:
	value = maxf(0.1, value)
	$Value.text = "%.1f×" % value
	Engine.time_scale = value
	Engine.physics_ticks_per_second = $"../TicksPerSecond/HSlider".value * value
