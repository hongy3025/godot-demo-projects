## 物理帧率滑块 —— 控制 Engine.physics_ticks_per_second。
extends HBoxContainer


func _on_h_slider_value_changed(value: float) -> void:
	$Value.text = str(roundi(value))
	Engine.physics_ticks_per_second = roundi(value * Engine.time_scale)
