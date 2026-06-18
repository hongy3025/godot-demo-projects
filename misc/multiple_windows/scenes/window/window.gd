## 窗口演示 —— 基础窗口行为。
##
## 继承自 [Window]，连接 close_requested 信号实现隐藏而非销毁。
extends Window


## _ready 入口，连接关闭请求信号。
func _ready() -> void:
	close_requested.connect(_on_close_requested)


## 关闭请求回调，隐藏窗口而非销毁。
func _on_close_requested() -> void:
	print("%s %s was hidden." % [str(get_class()), name])
	hide()
