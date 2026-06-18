## 触摸点跟踪辅助节点 —— 跟踪所有触摸指针的位置。
##
## 该节点监听未由其他方式处理的输入事件，在公共 `state` 字典中维护每个触摸指针的当前位置。
## 字典的键是触摸指针索引（整数），值是其位置（Vector2）。
## 它还会将操作系统传入的指针索引重新映射到可用的最低索引，使索引更友好。
## 可以方便地设置为单例（Singleton）。
extends Node


## 触摸状态字典。键为触摸指针索引（int），值为触摸位置（Vector2）。
## 公开给其他节点读取，例如用于绘制触摸点。
var state: Dictionary[int, Vector2] = {}


## 处理未处理的输入事件，跟踪屏幕触摸和拖拽。
##
## 功能：根据输入事件类型更新 `state` 字典中的触摸点信息。
## 参数：
##   input_event: 输入事件对象，可能是 InputEventScreenTouch 或 InputEventScreenDrag。
## 返回值：无
## 逻辑：如果是触摸按下事件，记录触摸位置；如果是触摸抬起事件，移除触摸记录；
##       如果是拖拽事件，更新触摸位置。每次处理后标记事件为已处理。
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventScreenTouch:
		if input_event.pressed:
			# 触摸按下：将触摸索引和位置存入 state 字典
			state[input_event.index] = input_event.position
		else:
			# 触摸抬起：从 state 字典中移除该触摸索引
			state.erase(input_event.index)
		get_viewport().set_input_as_handled()

	elif input_event is InputEventScreenDrag:
		# 触摸拖拽：更新 state 字典中对应触摸索引的位置
		state[input_event.index] = input_event.position
		get_viewport().set_input_as_handled()
