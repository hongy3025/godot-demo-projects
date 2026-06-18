## Screen capture demo implementation.
## 屏幕捕获演示脚本，演示如何从 Viewport 中捕获当前画面并显示为纹理。
# 继承自 Node，作为场景树中的独立节点运行，不依赖特定节点类型。
extends Node


## 用于显示捕获图像的 TextureRect 节点引用。
## 该节点在场景中负责展示从 Viewport 捕获的静态画面。
@onready var captured_image: TextureRect = $CapturedImage

## 触发屏幕捕获操作的按钮节点引用。
## 点击该按钮会执行一次 Viewport 画面捕获。
@onready var capture_button: Button = $CaptureButton


## 场景就绪时的初始化逻辑。
## _ready 是 Node 的内置虚函数，当节点及其子节点首次进入场景树时自动调用。
func _ready() -> void:
	# 将键盘/手柄焦点设置到捕获按钮上，方便非鼠标用户操作。
	capture_button.grab_focus()


## 捕获按钮按下时的回调函数。
## 通过信号连接自动触发，执行 Viewport 画面捕获并更新显示。
func _on_capture_button_pressed() -> void:
	# 获取当前 Viewport 的纹理数据，并从中提取 Image 对象。
	# get_viewport() 返回当前节点所在的 Viewport 引用。
	# get_texture() 获取该 Viewport 的渲染纹理。
	# get_image() 将纹理数据复制为可操作的 Image 对象（像素数据）。
	var img := get_viewport().get_texture().get_image()

	# 使用捕获到的 Image 数据创建新的 ImageTexture 纹理资源。
	# ImageTexture.create_from_image() 是 Godot 4 中从 Image 创建纹理的标准方法。
	var tex := ImageTexture.create_from_image(img)

	# 将新创建的纹理设置到 captured_image 节点上，更新显示画面。
	captured_image.set_texture(tex)

	# 用随机颜色修改按钮的色调，便于区分每次捕获对应的按钮状态。
	# Color.from_hsv() 通过 HSV 色彩模型创建颜色。
	# randf() 生成 0~1 的随机浮点数作为色相（H）。
	# randf_range(0.2, 0.8) 生成 0.2~0.8 的随机饱和度（S），避免过于灰暗或鲜艳。
	# 亮度（V）固定为 1.0，保持全亮。
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
