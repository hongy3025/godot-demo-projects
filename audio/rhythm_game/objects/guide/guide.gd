## 判定线指引节点 —— 按键时产生缩放动画反馈。
##
## 继承自 [Sprite2D]，当玩家按下主键时放大再恢复，
## 提供视觉上的按键反馈。
extends Sprite2D

## 缩放动画控制器。
var _guide_tween: Tween


## 每帧检测按键输入，触发缩放动画。
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"main_key"):
		scale = 1.2 * Vector2.ONE
		if _guide_tween:
			_guide_tween.kill()
		_guide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_guide_tween.tween_property(self, ^"scale", Vector2.ONE, 0.2)
