## 渐变条 —— 用于显示 SDR 和 HDR 颜色对比的 3D 可视化组件。
class_name GradientBars extends Node3D

## SDR 颜色条（标准动态范围）。
@export var sdr_bar: GeometryInstance3D
## HDR 颜色条（高动态范围）。
@export var hdr_bar: GeometryInstance3D
## 颜色值标签。
@export var label: Label3D

## 设置 HDR 条的步进数。
##
## 参数:
##   steps: 步进数
func set_num_steps(steps: int) -> void:
	var shader_mat: ShaderMaterial = hdr_bar.material_override as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter(&"steps", min(1, steps))

## 设置颜色并更新 SDR 和 HDR 条以及标签。
##
## 参数:
##   color: 要设置的颜色
func set_color(color: Color) -> void:
	var shader_mat: ShaderMaterial = sdr_bar.material_override as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter(&"my_color", color)

	shader_mat = hdr_bar.material_override as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter(&"my_color", color)

	label.text = "#" + color.to_html(false)
