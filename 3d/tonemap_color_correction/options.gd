## 色调映射和颜色校正选项控制器。
##
## 继承自 [VBoxContainer]，提供色调映射模式、曝光、白点、
## 颜色校正 LUT、饱和度和去条带化的实时调节。
extends VBoxContainer

## 可切换的测试场景列表。
@export var scenes: Array[PackedScene]

## 当前活动的测试场景。
var current_scene: TestScene = null
## 当前场景的 WorldEnvironment 引用。
var world_environment: WorldEnvironment = null

## _ready 入口。默认选择第一个场景。
func _ready():
	_on_scene_option_button_item_selected(0)

## 场景选择回调。切换测试场景并保留色调映射设置。
##
## 参数:
##   index: 场景索引
func _on_scene_option_button_item_selected(index):
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null

	var old_environment: Environment = null
	if world_environment != null:
		old_environment = world_environment.environment

	var new_scene: PackedScene = scenes[index]
	current_scene = new_scene.instantiate() as TestScene
	if current_scene:
		add_child(current_scene)

		world_environment = current_scene.world_environment
		if old_environment != null:
			world_environment.environment.tonemap_mode = old_environment.tonemap_mode
			world_environment.environment.tonemap_exposure = old_environment.tonemap_exposure
			world_environment.environment.tonemap_white = old_environment.tonemap_white
			world_environment.environment.adjustment_color_correction = old_environment.adjustment_color_correction
			world_environment.environment.adjustment_saturation = old_environment.adjustment_saturation


## 色调映射模式选择回调。
##
## 参数:
##   index: 色调映射模式索引
##
## Linear 和 AgX 色调映射不使用白点，隐藏白点设置。
func _on_tonemap_mode_item_selected(index: int) -> void:
	world_environment.environment.tonemap_mode = index as Environment.ToneMapper
	%Whitepoint.visible = world_environment.environment.tonemap_mode != Environment.TONE_MAPPER_LINEAR and world_environment.environment.tonemap_mode != Environment.TONE_MAPPER_AGX


## 曝光值变化回调。
##
## 参数:
##   value: 曝光值
func _on_exposure_value_changed(value: float) -> void:
	world_environment.environment.tonemap_exposure = value
	$TonemapMode/Exposure/Value.text = str(value).pad_decimals(1)


## 白点值变化回调。
##
## 参数:
##   value: 白点值
func _on_whitepoint_value_changed(value: float) -> void:
	world_environment.environment.tonemap_white = value
	$TonemapMode/Whitepoint/Value.text = str(value).pad_decimals(1)


## 颜色校正 LUT 选择回调。
##
## 参数:
##   index: LUT 索引
func _on_color_correction_item_selected(index: int) -> void:
	match index:
		0:  # 无
			world_environment.environment.adjustment_color_correction = null
		1:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/detect_white_clipping.png")
		2:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/frozen.png")
		3:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/heat.png")
		4:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/incandescent.png")
		5:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/posterized.png")
		6:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/posterized_outline.png")
		7:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/rainbow.png")
		8:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/1d/toxic.png")
		9:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/brighten_shadows.png")
		10:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/burned_blue.png")
		11:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/cold_color.png")
		12:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/detect_white_clipping.png")
		13:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/dithered.png")
		14:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/hue_shift.png")
		15:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/posterized.png")
		16:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/sepia.png")
		17:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/stressed.png")
		18:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/warm_color.png")
		19:
			world_environment.environment.adjustment_color_correction = preload("res://example_luts/3d/yellowen.png")


## 饱和度值变化回调。
##
## 参数:
##   value: 饱和度值
func _on_saturation_value_changed(value: float) -> void:
	world_environment.environment.adjustment_saturation = value
	$ColorCorrection/Saturation/Value.text = str(value).pad_decimals(1)


## 去条带化开关回调。
##
## 参数:
##   button_pressed: 是否启用去条带化
func _on_debanding_toggled(button_pressed: bool) -> void:
	get_viewport().use_debanding = button_pressed
