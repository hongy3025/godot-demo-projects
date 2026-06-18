## 对手棋子 —— 由 AI 控制的 Walker。
## 当前版本为被动角色，初始化后不处理帧更新。
extends Walker

func _ready() -> void:
	super._ready()
	# 对手默认不处理 _process，等待对话触发
	set_process(false)
