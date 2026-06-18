## HUD（抬头显示）—— 管理游戏 UI 的显示和交互。
## 继承自 CanvasLayer，显示消息、分数和开始按钮。
extends CanvasLayer

## 开始游戏信号。
signal start_game

## 显示一条临时消息（带计时器自动隐藏）。
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


## 显示游戏结束界面。
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()


## 更新分数显示。
func update_score(score):
	$ScoreLabel.text = str(score)


## 开始按钮点击回调：隐藏按钮并发射开始游戏信号。
func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()


## 消息计时器超时：隐藏消息标签。
func _on_MessageTimer_timeout():
	$MessageLabel.hide()
