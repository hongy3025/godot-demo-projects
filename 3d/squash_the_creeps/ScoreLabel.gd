## 分数标签 —— 显示玩家踩扁怪物的数量。
##
## 继承自 [Label]，每次收到 squashed 信号时增加分数。
extends Label

## 当前分数。
var score = 0

## 怪物被踩扁回调。增加分数并更新显示。
func _on_Mob_squashed():
	score += 1
	text = "分数: %s" % score
