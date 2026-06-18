## 物理插值开关 —— 控制全局物理插值。
extends CheckButton


func _on_check_button_toggled(toggled_on: bool) -> void:
	get_tree().physics_interpolation = toggled_on
