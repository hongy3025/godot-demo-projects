## 公主节点 —— 检测玩家进入触发胜利文本显示。
extends Node

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$"../WinText".show()
