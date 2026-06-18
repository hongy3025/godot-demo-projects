## 按钮互斥控制器 —— 控制一组按钮的禁用状态。
##
## 继承自 [BaseButton]，当自身被切换时启用或禁用其他按钮组。
## 支持两种行为模式：启用时禁用其他 / 禁用时启用其他。
extends BaseButton

## 行为枚举
enum Behavior {
	ENABLE_OTHERS_WHEN_ENABLED,   # 自身启用时启用其他
	ENABLE_OTHERS_WHEN_DISABLED,  # 自身禁用时启用其他
}

## 行为模式
@export var behavior: Behavior = Behavior.ENABLE_OTHERS_WHEN_ENABLED
## 受控的其他按钮列表
@export var others: Array[BaseButton] = []


## _ready 入口，根据初始状态设置其他按钮的禁用状态。
func _ready() -> void:
	var others_disabled: bool
	if behavior == Behavior.ENABLE_OTHERS_WHEN_ENABLED:
		others_disabled = not button_pressed
	else:
		others_disabled = button_pressed
	for other in others:
		other.disabled = others_disabled


## 按钮切换回调，更新其他按钮的禁用状态。
func _toggled(toggled_on: bool) -> void:
	if behavior == Behavior.ENABLE_OTHERS_WHEN_ENABLED:
		for other in others:
			other.disabled = not toggled_on
	else:
		for other in others:
			other.disabled = toggled_on
