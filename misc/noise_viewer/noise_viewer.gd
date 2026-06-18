## 噪声查看器 —— 可视化 FastNoiseLite 噪声参数效果。
##
## 继承自 [Control]，提供滑块和旋钮调整噪声的种子、频率、分形参数等。
## 实时更新 ShaderMaterial 参数以改变噪声显示效果。
extends Control


## FastNoiseLite 噪声对象
@onready var noise: FastNoiseLite = $SeamlessNoiseTexture.texture.noise

# 噪声最小/最大值，用于着色器裁剪
var min_noise: float = -1.0
var max_noise: float = 1.0


## _ready 入口，初始化 UI 控件值并渲染噪声。
func _ready() -> void:
	# 用噪声的当前值设置 UI 控件
	$ParameterContainer/SeedSpinBox.value = noise.seed
	$ParameterContainer/FrequencySpinBox.value = noise.frequency
	$ParameterContainer/FractalOctavesSpinBox.value = noise.fractal_octaves
	$ParameterContainer/FractalGainSpinBox.value = noise.fractal_gain
	$ParameterContainer/FractalLacunaritySpinBox.value = noise.fractal_lacunarity

	# 渲染噪声
	_refresh_shader_params()


## 更新着色器参数以匹配当前噪声范围。
func _refresh_shader_params() -> void:
	# 将 min/max 映射到 [0, 1] 范围供着色器使用
	@warning_ignore("integer_division")
	var _min := (min_noise + 1) / 2
	@warning_ignore("integer_division")
	var _max := (max_noise + 1) / 2
	var _material: ShaderMaterial = $SeamlessNoiseTexture.material
	_material.set_shader_parameter(&"min_value", _min)
	_material.set_shader_parameter(&"max_value", _max)


## 打开 FastNoiseLite 文档。
func _on_documentation_button_pressed() -> void:
	OS.shell_open("https://docs.godotengine.org/en/latest/classes/class_fastnoiselite.html")


## 随机生成种子值。
func _on_random_seed_button_pressed() -> void:
	$ParameterContainer/SeedSpinBox.value = floor(randf_range(-2147483648, 2147483648))


## 种子值变化回调。
func _on_seed_spin_box_value_changed(value: float) -> void:
	noise.seed = int(value)


## 频率值变化回调。
func _on_frequency_spin_box_value_changed(value: float) -> void:
	noise.frequency = value


## 分形八度值变化回调。
func _on_fractal_octaves_spin_box_value_changed(value: float) -> void:
	noise.fractal_octaves = int(value)


## 分形增益值变化回调。
func _on_fractal_gain_spin_box_value_changed(value: float) -> void:
	noise.fractal_gain = value


## 分形间隙值变化回调。
func _on_fractal_lacunarity_spin_box_value_changed(value: float) -> void:
	noise.fractal_lacunarity = value


## 最小值裁剪旋钮变化回调。
func _on_min_clip_spin_box_value_changed(value: float) -> void:
	min_noise = value
	_refresh_shader_params()


## 最大值裁剪旋钮变化回调。
func _on_max_clip_spin_box_value_changed(value: float) -> void:
	max_noise = value
	_refresh_shader_params()
