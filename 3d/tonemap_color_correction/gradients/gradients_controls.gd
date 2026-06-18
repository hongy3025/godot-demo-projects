## 渐变控制面板 —— 管理多个渐变条的步进、颜色和指数视图。
##
## 继承自 [Node]，控制多个 GradientBars 的显示参数。
extends Node

## 所有渐变条的节点路径列表。
@export var bars: Array[NodePath]
## 最大值显示标签。
@export var max_value_label: Label3D
## 预设颜色列表。
@export var colors: Array[Color]
## 自定义颜色渐变条。
@export var custom_bar: GradientBars
## 色相网格 MeshInstance3D。
@export var hues: MeshInstance3D

## _ready 入口。初始化颜色和默认参数。
func _ready():
	for i in range(colors.size()):
		var bar_path: NodePath = bars[i]
		var bar: GradientBars = get_node(bar_path) as GradientBars
		var col: Color = colors[i]
		bar.set_color(col)

	_on_steps_value_changed(6)
	_on_color_picker_button_color_changed(Color(0.5, 0.5, 0.5, 1))
	_on_exponential_toggled(false)

## 步进值变化回调。更新所有渐变条和色相网格的步进参数。
##
## 参数:
##   value: 步进值
func _on_steps_value_changed(value):
	max_value_label.text = "%.1f" % value
	for bar_path in bars:
		var bar = get_node(bar_path)
		var shader_mat = bar.hdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter(&"steps", value)
	if hues:
		var shader_mat = hues.material_override as ShaderMaterial
		shader_mat.set_shader_parameter(&"steps", value)


## 颜色选择器颜色变化回调。更新自定义渐变条的颜色。
##
## 参数:
##   color: 新颜色
func _on_color_picker_button_color_changed(color):
	if custom_bar:
		custom_bar.set_color(color)


## 指数视图切换回调。切换所有渐变条和色相网格的指数显示模式。
##
## 参数:
##   button_pressed: 是否启用指数视图
func _on_exponential_toggled(button_pressed):
	for bar_path in bars:
		var bar = get_node(bar_path)
		var shader_mat = bar.hdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter(&"exponential_view", button_pressed)

		shader_mat = bar.sdr_bar.material_override as ShaderMaterial
		shader_mat.set_shader_parameter(&"exponential_view", button_pressed)
	if hues:
		var shader_mat = hues.material_override as ShaderMaterial
		shader_mat.set_shader_parameter(&"exponential_view", button_pressed)
