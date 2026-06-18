## 文本字段演示 —— 带提交按钮的文本输入框。
##
## 继承自 [LineEdit]，提交后自动清空内容。
## 支持通过 @export 关联的外部按钮触发提交。
extends LineEdit


## 外部提交按钮（可选）
@export var submit_button: Button


## _ready 入口，连接提交信号和外部按钮。
func _ready() -> void:
	text_submitted.connect(func(_s): clear(), ConnectFlags.CONNECT_DEFERRED)
	if submit_button:
		submit_button.pressed.connect(func(): text_submitted.emit(text))
