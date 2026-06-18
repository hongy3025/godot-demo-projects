## 暂停标签 —— 游戏暂停时显示"暂停"文字。
extends Label


func _process(_delta: float) -> void:
	visible = get_tree().paused
