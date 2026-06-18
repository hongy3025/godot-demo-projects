## 金币计数器 —— 显示已收集金币数量。
class_name CoinsCounter
extends Panel

## 已收集金币数量。
var _coins_collected: int = 0

@onready var _coins_label := $Label as Label


func _ready() -> void:
	_coins_label.set_text(str(_coins_collected))
	($AnimatedSprite2D as AnimatedSprite2D).play()


## 收集一枚金币。
func collect_coin() -> void:
	_coins_collected += 1
	_coins_label.set_text(str(_coins_collected))
