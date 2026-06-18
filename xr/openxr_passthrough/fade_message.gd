## 淡入淡出消息 3D 节点 —— 在 3D 空间中显示带淡出效果的文本消息。
## 使用类名注册为 [code]FadeMessage3D[/code]。
## 继承自 [Node3D]，自动创建 [Label3D] 子节点，支持延迟后淡出消失。
@tool
class_name FadeMessage3D
extends Node3D

## 要显示的文本。赋值后自动开始淡出计时。
@export var text : String = "":
	set(value):
		text = value
		if is_inside_tree():
			_update_text()

## 文本颜色。
@export var text_color : Color = Color(1.0, 1.0, 1.0):
	set(value):
		text_color = value
		if is_inside_tree():
			_update_color()

## 文本在屏幕上停留的持续时间（秒），之后开始淡出。
@export_range(0.1, 10.0, 0.1, "suffix:s") var fade_duration : float = 0.5

## 淡出延迟时间（秒），即文本显示多久后开始淡出。
@export_range(0.1, 10.0, 0.1, "suffix:s") var fade_delay : float = 1.0

## 内部的 [Label3D] 节点引用。
var _label : Label3D
## 剩余延迟时间。
var _delay : float = 1.0
## 当前透明度（0.0~1.0）。
var _modulate : float = 1.0


## 更新标签文本 —— 根据文本内容设置显示或隐藏。
## 在编辑器中不应用淡出效果，显示占位文本。
func _update_text():
	if Engine.is_editor_hint():
		# 在编辑器中不应用淡出
		if text.is_empty():
			_label.text = "FadeMessage3D"
			_update_color()
		else:
			_label.text = text
			_update_color()
	elif text.is_empty():
		_modulate = 0.0
		_label.visible = false
		set_process(false)
	else:
		_delay = fade_delay
		_modulate = 1.0
		_label.text = text
		_label.visible = true
		_update_color()
		set_process(true)


## 更新文本颜色和透明度。
func _update_color():
	_label.modulate = Color(text_color.r, text_color.g, text_color.b, _modulate)
	_label.outline_modulate = Color(0.0, 0.0, 0.0, _modulate)


## _ready 初始化 —— 创建 [Label3D] 子节点并设置初始状态。
func _ready():
	_label = Label3D.new()
	_label.pixel_size = 0.002
	add_child(_label, false, Node.INTERNAL_MODE_BACK)

	_update_text()
	_update_color()


## _process 每帧更新 —— 处理延迟等待和淡出动画。
## 参数:
##   delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 编辑器模式下不处理
##   2. 透明度为 0 时隐藏并停止处理
##   3. 先等待延迟时间
##   4. 延迟结束后逐步降低透明度直到完全消失
func _process(delta):
	if Engine.is_editor_hint():
		set_process(false)
		return

	# 透明度归零后隐藏并停止处理
	if _modulate == 0.00:
		_label.visible = false
		set_process(false)
		return

	# 等待延迟时间
	if _delay > 0.0:
		_delay = max(0.0, _delay - delta)
		return

	# 淡出：逐渐降低透明度
	_modulate = max(0.0, _modulate - delta / fade_duration)
	_update_color()
