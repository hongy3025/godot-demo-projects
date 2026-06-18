## HDR 颜色扫描演示 —— 在 HDR 范围内扫描颜色值。
##
## 继承自 [Control]，通过滑块控制颜色扫描的最小/最大范围，
## 实时更新着色器参数，展示 HDR 输出中不同亮度级别的颜色表现。
extends Control

## 是否裁剪到最大亮度
var clip_to_max_lum: bool = false


## _process 入口，每帧更新扫描范围和标签显示。
func _process(_delta: float) -> void:
	var window: Window = get_window()
	var window_id = get_window().get_window_id()
	var sm: ShaderMaterial = %ColorSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter(&"max_value", window.get_output_max_linear_value());
	%SweepMinLabel.text = "%0.3f (%0.2f nits)" % [pow(2, %MinHSlider.value), pow(2, %MinHSlider.value) * DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)]
	%SweepMaxLabel.text = "%0.2f (%0.2f nits)" % [pow(2, %MaxHSlider.value), pow(2, %MaxHSlider.value) * DisplayServer.window_get_hdr_output_current_reference_luminance(window_id)]


## 最小值滑块变化回调。
func _on_min_h_slider_value_changed(value: float) -> void:
	%MaxHSlider.min_value = value;
	var sm: ShaderMaterial = %ColorSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter(&"log2_min", value)


## 最大值滑块变化回调。
func _on_max_h_slider_value_changed(value: float) -> void:
	%MinHSlider.max_value = value;
	var sm: ShaderMaterial = %ColorSweepMesh.material as ShaderMaterial
	sm.set_shader_parameter(&"log2_max", value)
