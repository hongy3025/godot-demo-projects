## RichTextLabel BBCode 演示 —— 展示 RichTextLabel 的 BBCode 链接和暂停功能。
## 继承自 [Control]，处理 RichTextLabel 中的元数据点击和游戏暂停切换。
extends Control


## RichTextLabel 元数据（链接）点击回调：通过系统默认浏览器打开链接。
func _on_RichTextLabel_meta_clicked(meta: Variant) -> void:
	var err := OS.shell_open(str(meta))
	if err == OK:
		print("Opened link '%s' successfully!" % str(meta))
	else:
		print("Failed opening the link '%s'!" % str(meta))


## 暂停开关切换回调：控制游戏暂停状态。
func _on_pause_toggled(button_pressed: bool) -> void:
	get_tree().paused = button_pressed
