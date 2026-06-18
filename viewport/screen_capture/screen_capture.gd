## 屏幕截图演示 —— 捕获当前视口的渲染内容并显示在 UI 中。
##
## 继承自 [Node]，演示如何使用 get_viewport().get_texture().get_image()
## 获取视口的像素数据并创建纹理显示。
extends Node

## 用于显示截图的 TextureRect 节点。
@onready var captured_image: TextureRect = $CapturedImage
## 触发截图的按钮。
@onready var capture_button: Button = $CaptureButton


## 初始化：让捕获按钮获得焦点，方便键盘/手柄操作。
func _ready() -> void:
	capture_button.grab_focus()


## 响应按钮点击：捕获当前视口图像并显示。
## 同时随机改变按钮颜色以区分每次截图。
func _on_capture_button_pressed() -> void:
	# 从视口获取渲染纹理并提取 Image 数据
	var img := get_viewport().get_texture().get_image()

	# 将 Image 数据创建为可显示的 ImageTexture
	var tex := ImageTexture.create_from_image(img)

	# 将纹理设置到截图显示节点
	captured_image.set_texture(tex)

	# 随机改变按钮颜色，便于区分每次截图对应的按钮
	capture_button.modulate = Color.from_hsv(randf(), randf_range(0.2, 0.8), 1.0)
