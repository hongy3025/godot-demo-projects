## 触屏 UI 控制器 —— 在触屏设备上显示虚拟摇杆。
##
## 继承自 [CanvasLayer]，检测到触屏设备时显示 UI。
extends CanvasLayer


## _ready 入口。检测触屏设备并控制可见性。
func _ready() -> void:
	hide()
	if DisplayServer.is_touchscreen_available():
		show()
