## URL 打开器 —— 点击 RichTextLabel 中的链接时用默认浏览器打开。
##
## 继承自 [RichTextLabel]，连接 meta_clicked 信号调用 OS.shell_open。
extends RichTextLabel


## _ready 入口，连接元链接点击信号。
func _ready() -> void:
	meta_clicked.connect(_on_meta_clicked)


## 元链接点击回调，用默认浏览器打开链接。
func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
