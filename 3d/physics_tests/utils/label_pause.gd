## 暂停状态显示标签 —— 游戏暂停时可见。
extends Label


func _process(_delta: float) -> void:
	visible = get_tree().paused
