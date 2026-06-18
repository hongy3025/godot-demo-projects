## 弹出窗口 —— 鼠标离开时自动隐藏。
##
## 继承自 [Popup]，连接 mouse_exited 信号实现自动隐藏。
extends Popup


## _ready 入口，连接鼠标离开信号。
func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited)


## 鼠标离开回调，隐藏弹出窗口。
func _on_mouse_exited():
	hide()
