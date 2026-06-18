## 可滚动日志容器 —— 支持自动滚动和手动滚动切换。
extends ScrollContainer

## 是否自动滚动到底部。
@export var auto_scroll: bool = false

func _ready() -> void:
	var scrollbar := get_v_scroll_bar()
	scrollbar.scrolling.connect(_on_scrolling)


func _process(_delta: float) -> void:
	if auto_scroll:
		var scrollbar := get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value


## 用户手动滚动时取消自动滚动。
func _on_scrolling() -> void:
	auto_scroll = false
	$"../CheckBoxScroll".button_pressed = false


## 复选框切换回调。
func _on_check_box_scroll_toggled(button_pressed: bool) -> void:
	auto_scroll = button_pressed
