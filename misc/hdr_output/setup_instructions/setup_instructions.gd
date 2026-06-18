## HDR 设置说明 —— 点击链接打开文档。
##
## 继承自 [RichTextLabel]，点击元链接时用默认浏览器打开。
extends RichTextLabel


## 元链接点击回调。
func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
