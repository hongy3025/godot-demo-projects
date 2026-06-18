## 分屏游戏控制器 —— 为双人分屏设置第二个视口和摄像机。
extends Game


func _ready() -> void:
	var player_2 := %Player2 as Player
	var viewport_1 := %Viewport1 as SubViewport
	var viewport_2 := %Viewport2 as SubViewport
	# 共享同一个 2D 世界（物理和渲染）
	viewport_2.world_2d = viewport_1.world_2d
	player_2.camera.custom_viewport = viewport_2
	player_2.camera.make_current()
