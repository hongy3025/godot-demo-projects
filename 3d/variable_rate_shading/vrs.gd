## 可变速率着色（VRS）演示场景控制器。
##
## 继承自 [Node3D]，演示 VRS 的三种模式：禁用、纹理和 XR。
extends Node3D


## VRS 模式选择 OptionButton。
@onready var option_button: OptionButton = $CanvasLayer/VBoxContainer/HBoxContainer/OptionButton
## VRS 纹理显示。
@onready var texture_rect: TextureRect = $CanvasLayer/VBoxContainer/TextureRect
## 默认摄像机。
@onready var camera: Camera3D = $Camera3D
## XR 摄像机。
@onready var xr_camera: Camera3D = $XROrigin3D/XRCamera3D

## VRS 纹理资源。
@export var texture: Texture

## XR 接口引用。
var xr_interface: MobileVRInterface


## 设置 XR 模式。初始化或卸载 XR 接口。
func _set_xr_mode() -> void:
	var vrs_mode := get_viewport().vrs_mode
	if vrs_mode == Viewport.VRS_XR:
		xr_interface = XRServer.find_interface("Native mobile")
		if xr_interface and xr_interface.initialize():
			xr_interface.eye_height = 0.0
			xr_interface.k1 = 0.0
			xr_interface.k2 = 0.0
			xr_interface.oversample = 1.0

			get_viewport().use_xr = true
			xr_camera.current = true

			$XROrigin3D.global_transform = camera.global_transform
	else:
		if xr_interface:
			xr_interface.uninitialize()

		get_viewport().use_xr = false
		camera.current = true


## 更新 VRS 纹理显示。
func _update_texture() -> void:
	var vrs_mode := get_viewport().vrs_mode
	if vrs_mode == Viewport.VRS_DISABLED:
		texture_rect.visible = false
	elif vrs_mode == Viewport.VRS_TEXTURE:
		get_viewport().vrs_texture = texture
		texture_rect.texture = texture
		texture_rect.visible = true
	elif vrs_mode == Viewport.VRS_XR:
		texture_rect.visible = false


## _ready 入口。初始化 VRS 模式选择。
func _ready() -> void:
	var vrs_mode := get_viewport().vrs_mode
	option_button.selected = vrs_mode
	_update_texture()


## VRS 模式选择回调。
##
## 参数:
##   index: VRS 模式索引
func _on_option_button_item_selected(index: int) -> void:
	get_viewport().vrs_mode = index as Viewport.VRSMode
	_set_xr_mode()
	_update_texture()
