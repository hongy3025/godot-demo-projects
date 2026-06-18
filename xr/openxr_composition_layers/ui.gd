## 合成层 UI 节点 —— 处理鼠标光标在 UI 上的移动。
## 继承自 [Control]，跟踪鼠标位置并移动自定义光标图像。
extends Control

## 按钮点击计数器。
var button_count : int = 0


## _input 输入处理 —— 移动光标位置。
## 参数:
##   event: 输入事件
##
## 当鼠标移动时，更新光标位置到鼠标位置偏移 (16, 16) 处。
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(16, 16)


## 按钮点击回调 —— 增加计数并更新显示文本。
func _on_button_pressed():
	button_count = button_count + 1
	$CountLabel.text = "The button has been pressed %d times!" % [ button_count ]
