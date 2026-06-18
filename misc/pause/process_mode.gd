## 暂停演示 —— 动画处理模式选择器。
##
## 继承自 [OptionButton]，提供下拉菜单选择立方体动画的 process_mode。
## 演示 [AnimationPlayer] 的 process_mode 属性在不同暂停状态下的行为差异。
extends OptionButton


## 立方体动画播放器引用
@onready var cube_animation: AnimationPlayer = $"../../AnimationPlayer"


## 选项下拉菜单选择回调，设置动画的处理模式。
func _on_option_button_item_selected(index: int) -> void:
	cube_animation.process_mode = index as ProcessMode
