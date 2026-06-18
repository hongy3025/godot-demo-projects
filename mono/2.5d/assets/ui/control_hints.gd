## 控制提示 UI —— 用于显示/隐藏操作提示信息。
##
## 继承自 [Control]，作为 UI 元素显示在屏幕上。
## 按 Toggle Control Hints 键（默认设置）可以切换其可见性。
extends Control


## _process 每帧调用，检测切换按键输入并切换可见性。
##
## 功能：
##   监听 "toggle_control_hints" 操作按键，按下时切换 visible 属性。
##
## 参数：
##   _delta: 上一帧到当前帧的时间差（秒），此处未使用
func _process(_delta):
	# 检测 "toggle_control_hints" 动作是否刚被按下
	# 使用 Input.is_action_just_pressed 确保只触发一次
	if Input.is_action_just_pressed(&"toggle_control_hints"):
		# 切换可见性：可见 -> 隐藏，隐藏 -> 可见
		visible = not visible
