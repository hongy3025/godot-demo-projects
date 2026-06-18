## 加载场景 —— 在主要场景完全加载前显示的过渡场景。
##
## 继承自 [Control]，等待两帧后切换到主场景，确保加载文本能够显示。
extends Control


## _ready 入口。等待两帧后加载主场景。
func _ready() -> void:
	for i in 2:
		# 等待两帧后再切换到主场景，使加载文本能够显示而不是闪现。
		await get_tree().process_frame

	# 不使用 `preload()` 以避免在加载文本显示之前产生加载时间。
	get_tree().change_scene_to_packed(load("res://test.tscn"))
