## 音符节点 —— 节奏游戏中的单个可击打音符。
##
## 继承自 [Node2D]，根据节拍位置在屏幕上滚动，
## 被击打时播放对应的视觉反馈动画（Perfect/Good/Miss）。
class_name Note
extends Node2D

@export_category("Nodes")
## 节拍控制器引用。
@export var conductor: Conductor

@export_category("Settings")
## 水平偏移量（像素），用于多列布局。
@export var x_offset: float = 0
## 音符所在的节拍位置。
@export var beat: float = 0

## 当前滚动速度（像素/秒），从 GlobalSettings 获取。
var _speed: float
## 是否暂停移动（击打后停止移动）。
var _movement_paused: bool = false
## 当前节拍与音符节拍的时间差（秒）。
var _song_time_delta: float = 0


func _init() -> void:
	_speed = GlobalSettings.scroll_speed


func _ready() -> void:
	GlobalSettings.scroll_speed_changed.connect(_on_scroll_speed_changed)


## 每帧更新音符位置。
func _process(_delta: float) -> void:
	if _movement_paused:
		return

	_update_position()


## 更新音符的节拍时间差并重新计算位置。
## curr_beat: 当前节拍
func update_beat(curr_beat: float) -> void:
	_song_time_delta = (curr_beat - beat) * conductor.get_beat_duration()

	_update_position()


## Perfect 击打反馈：变黄、放大并渐隐消失。
func hit_perfect() -> void:
	_movement_paused = true

	modulate = Color.YELLOW

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property($Sprite2D, ^"scale", 1.5 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


## Good 击打反馈：变蓝、放大并渐隐消失。
func hit_good() -> void:
	_movement_paused = true

	modulate = Color.DEEP_SKY_BLUE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property($Sprite2D, ^"scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


## Miss 反馈：变红并渐隐消失。
## stop_movement: 是否停止移动（自动 Miss 时通常为 false，按键 Miss 时为 true）
func miss(stop_movement: bool = true) -> void:
	_movement_paused = stop_movement

	modulate = Color.DARK_RED

	var tween := create_tween()
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)


## 更新音符的屏幕位置。
## 使用二次函数使音符越过判定线后减速，模拟"穿过"效果。
func _update_position() -> void:
	if _song_time_delta > 0:
		# 音符经过判定线后减速
		position.y = _speed * _song_time_delta - _speed * pow(_song_time_delta, 2)
	else:
		position.y = _speed * _song_time_delta
	position.x = x_offset


## 滚动速度变化回调：更新音符的移动速度。
func _on_scroll_speed_changed(speed: float) -> void:
	_speed = speed
