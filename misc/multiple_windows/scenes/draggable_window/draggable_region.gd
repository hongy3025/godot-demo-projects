## 可拖拽区域 —— 点击区域拖拽窗口。
##
## 继承自 [Area2D]，接收鼠标输入事件后调用窗口的 start_drag 方法。
extends Area2D


## _input_event 入口，处理鼠标点击事件启动窗口拖拽。
func _input_event(_viewport: Viewport, input_event: InputEvent, _shape_index: int) -> void:
	if input_event is InputEventMouseButton:
		if input_event.pressed:
			get_window().start_drag()
