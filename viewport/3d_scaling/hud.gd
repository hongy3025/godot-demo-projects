## 3D 缩放 HUD —— 控制 3D 视口的缩放因子和过滤模式。
##
## 继承自 [Control]，提供 UI 界面让用户调整 3D 渲染的缩放比例和采样过滤方式。
## 缩放因子越低（如 1），画质越清晰但性能开销越大；
## 缩放因子越高（如 4），画质越模糊但性能越好。
extends Control

## 3D 视口的缩放因子。例如 1 为全分辨率，2 为半分辨率，4 为四分之一分辨率。
## 值越小画面越锐利，但渲染速度越慢。
var scale_factor: int = 1

## 3D 缩放过滤模式，默认为双线性过滤。
var filter_mode := Viewport.SCALING_3D_MODE_BILINEAR

## 主视口（根窗口）的引用。
@onready var viewport: Window = get_tree().root
## 显示当前缩放比例的标签。
@onready var scale_label: Label = $VBoxContainer/Scale
## 显示当前过滤模式的标签。
@onready var filter_label: Label = $VBoxContainer/Filter


## 初始化：设置视口的 3D 缩放过滤模式。
func _ready() -> void:
	viewport.scaling_3d_mode = filter_mode


## 处理未处理的输入事件：切换缩放比例或过滤模式。
## 参数:
##   input_event: 输入事件对象
##
## 按键说明：
##   cycle_viewport_resolution: 循环切换缩放比例 (1/1, 1/2, 1/3, 1/4)
##   toggle_filtering: 循环切换过滤模式（双线性、FSR 等）
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"cycle_viewport_resolution"):
		scale_factor = wrapi(scale_factor + 1, 1, 5)
		viewport.scaling_3d_scale = 1.0 / scale_factor
		scale_label.text = "Scale: %3.0f%%" % (100.0 / scale_factor)

	if input_event.is_action_pressed(&"toggle_filtering"):
		filter_mode = wrapi(filter_mode + 1, Viewport.SCALING_3D_MODE_BILINEAR, Viewport.SCALING_3D_MODE_MAX) as Viewport.Scaling3DMode
		viewport.scaling_3d_mode = filter_mode
		filter_label.text = (
				ClassDB.class_get_enum_constants(&"Viewport", &"Scaling3DMode")[filter_mode]
						.capitalize()
						.replace("3d", "3D")
						.replace("Mode", "Mode:")
						.replace("Fsr", "FSR")
			)
