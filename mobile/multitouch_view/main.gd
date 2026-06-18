## 多点触控视图主脚本 —— 在画布上绘制所有触摸点。
##
## 该脚本继承自 [Node2D]，每帧通过 TouchHelper 单例获取所有触摸指针的位置，
## 并在屏幕上绘制彩色圆点来可视化每个触摸点。
extends Node2D


## 每帧处理 —— 请求重绘。
##
## 功能：每帧调用 `queue_redraw()` 触发 `_draw()` 回调，保持触摸点实时更新。
## 参数：
##   _delta: 帧时间增量（float），此处未使用
## 返回值：无
func _process(_delta: float) -> void:
	# 每帧请求重绘
	queue_redraw()


## 绘制触摸点 —— 在屏幕上绘制每个触摸指针的位置。
##
## 功能：遍历 TouchHelper 单例中记录的所有触摸指针，在对应位置绘制半透明圆形。
## 参数：无
## 返回值：无
func _draw() -> void:
	# 获取 TouchHelper 单例
	var touch_helper: Node = $"/root/TouchHelper"
	# 遍历每个触摸指针，绘制圆形
	for ptr_index: int in touch_helper.state.keys():
		var pos: Vector2 = touch_helper.state[ptr_index]
		var color := _get_color_for_ptr_index(ptr_index)
		color.a = 0.75
		draw_circle(pos, 40.0, color)


## 根据触摸索引生成唯一颜色。
##
## 功能：为每个触摸指针索引生成一个独特的颜色，便于区分不同触摸点。
## 参数：
##   index: 触摸指针索引（int）
## 返回值：对应的颜色（Color）
## 算法：利用索引的低 3 位（模 7+1）分别映射到 R、G、B 通道。
func _get_color_for_ptr_index(index: int) -> Color:
	var x := (index % 7) + 1
	return Color(float(bool(x & 1)), float(bool(x & 2)), float(bool(x & 4)))
