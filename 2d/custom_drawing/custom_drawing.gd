## 自定义绘制主控制器 —— 管理 MSAA 和抗锯齿切换。
extends Control


## MSAA 下拉菜单选择回调。
func _on_msaa_2d_item_selected(index: int) -> void:
	get_viewport().msaa_2d = index as Viewport.MSAA


## 抗锯齿切换回调：更新所有标签页的抗锯齿设置并强制重绘。
func _on_draw_antialiasing_toggled(toggled_on: bool) -> void:
	var nodes: Array[Node] = %TabContainer.get_children()
	nodes.push_back(%AnimationSlice)
	for tab: Control in nodes:
		tab.use_antialiasing = toggled_on
		tab.queue_redraw()
