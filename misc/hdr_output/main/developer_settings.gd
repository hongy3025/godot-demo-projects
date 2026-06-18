## HDR 开发者设置 —— 显示 HDR 亮度调整的可视化参考。
##
## 继承自 [VBoxContainer]，根据当前最大线性值计算并显示
## 不同调整步长下的亮度颜色参考。
extends VBoxContainer


## _process 入口，每帧更新亮度参考颜色。
func _process(_delta: float) -> void:
	var window: Window = get_window()
	var adjustment_step_1 = 0.2
	var adjustment_step_2 = 0.4

	var max_val: float = window.get_output_max_linear_value()

	%MaxLumAdjustBacking.color = Color(max_val, max_val, max_val).linear_to_srgb()

	var max_adjust_material_value = pow(2.0, (log(max_val) / log(2.0)) - adjustment_step_2)
	%MaxLumAdjustBelow2.self_modulate = Color(max_adjust_material_value, max_adjust_material_value, max_adjust_material_value).linear_to_srgb()

	max_adjust_material_value = pow(2.0, (log(max_val) / log(2.0)) - adjustment_step_1)
	%MaxLumAdjustBelow3.self_modulate = Color(max_adjust_material_value, max_adjust_material_value, max_adjust_material_value).linear_to_srgb()

	# 示例

	max_adjust_material_value = pow(2.0, (log(1.0) / log(2.0)) - adjustment_step_2)
	%ExampleMaxLumAdjustBelow.self_modulate = Color(max_adjust_material_value, max_adjust_material_value, max_adjust_material_value).linear_to_srgb()

	max_adjust_material_value = pow(2.0, (log(1.0) / log(2.0)) - adjustment_step_1)
	%ExampleMaxLumAdjustBelow2.self_modulate = Color(max_adjust_material_value, max_adjust_material_value, max_adjust_material_value).linear_to_srgb()
