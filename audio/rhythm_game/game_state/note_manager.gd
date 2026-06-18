## 音符管理器 —— 负责音符的生成、更新和击打判定。
##
## 继承自 [Node2D]，根据曲谱数据生成音符实例，每帧更新音符位置，
## 检测玩家按键输入并进行击打判定（Perfect/Good/Miss）。
class_name NoteManager
extends Node2D

## 统计数据更新信号。
signal play_stats_updated(play_stats: PlayStats)
## 音符击打信号，传递节拍、判定类型和误差。
signal note_hit(beat: float, hit_type: Enums.HitType, hit_error: float)
## 歌曲结束信号。
signal song_finished(play_stats: PlayStats)

## 音符场景预加载。
const NOTE_SCENE = preload("res://objects/note/note.tscn")
## Perfect 判定时间窗口（秒）：±50ms。
const HIT_MARGIN_PERFECT = 0.050
## Good 判定时间窗口（秒）：±150ms。
const HIT_MARGIN_GOOD = 0.150
## Miss 判定时间窗口（秒）：±300ms。超出此范围视为未击打。
const HIT_MARGIN_MISS = 0.300

## 节拍控制器引用。
@export var conductor: Conductor
## 使用的时间类型（滤波后/原始）。
@export var time_type: Enums.TimeType = Enums.TimeType.FILTERED
## 当前曲谱。
@export var chart: ChartData.Chart = ChartData.Chart.THE_COMEBACK

## 所有活跃音符的数组。
var _notes: Array[Note] = []

## 统计数据实例。
var _play_stats: PlayStats
## 击打误差累积值，用于计算平均误差。
var _hit_error_acc: float = 0.0
## 击打总次数。
var _hit_count: int = 0


## 初始化：创建统计实例、解析曲谱数据并生成音符。
func _ready() -> void:
	_play_stats = PlayStats.new()
	_play_stats.changed.connect(
			func() -> void:
				play_stats_updated.emit(_play_stats)
				)

	var chart_data := ChartData.get_chart_data(chart)

	# 解析曲谱数据，提取所有音符的节拍位置
	var note_beats: Array[float] = []
	for measure_i in range(chart_data.size()):
		var measure: Array = chart_data[measure_i]
		var subdivision := 1.0 / measure.size() * 4
		for note_i: int in range(measure.size()):
			var beat := measure_i * 4 + note_i * subdivision
			if measure[note_i] == 1:
				note_beats.append(beat)

	# 为每个节拍位置创建音符实例
	for beat in note_beats:
		var note := NOTE_SCENE.instantiate() as Note
		note.beat = beat
		note.conductor = conductor
		note.update_beat(-100)
		add_child(note)
		_notes.append(note)


## 每帧更新音符位置、检测漏掉的音符和处理按键输入。
func _process(_delta: float) -> void:
	if _notes.is_empty():
		return

	var curr_beat := _get_curr_beat()
	for i in range(_notes.size()):
		_notes[i].update_beat(curr_beat)

	# 检测已过判定窗口的音符（Miss）
	_miss_old_notes()

	# 检测按键输入
	if Input.is_action_just_pressed(&"main_key"):
		_handle_keypress()

	if _notes.is_empty():
		_finish_song()


## 检测并处理已过判定窗口的音符（自动 Miss）。
func _miss_old_notes() -> void:
	while not _notes.is_empty():
		var note := _notes[0] as Note
		var note_delta := _get_note_delta(note)

		if note_delta > HIT_MARGIN_GOOD:
			# 当前时间已超过音符的 Good 判定窗口，自动 Miss
			note.miss(false)
			_notes.remove_at(0)
			_play_stats.miss_count += 1
			note_hit.emit(note.beat, Enums.HitType.MISS_LATE, note_delta)
		else:
			# 音符仍在可击打范围内，停止检查后续音符
			break


## 处理按键输入：对最前面的音符进行击打判定。
func _handle_keypress() -> void:
	var note := _notes[0] as Note
	var hit_delta := _get_note_delta(note)
	if hit_delta < -HIT_MARGIN_MISS:
		# 音符还未进入判定窗口，不做处理
		pass
	elif -HIT_MARGIN_PERFECT <= hit_delta and hit_delta <= HIT_MARGIN_PERFECT:
		# 完美时机
		note.hit_perfect()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.perfect_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		note_hit.emit(note.beat, Enums.HitType.PERFECT, hit_delta)
	elif -HIT_MARGIN_GOOD <= hit_delta and hit_delta <= HIT_MARGIN_GOOD:
		# 略早或略晚
		note.hit_good()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.good_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		if hit_delta < 0:
			note_hit.emit(note.beat, Enums.HitType.GOOD_EARLY, hit_delta)
		else:
			note_hit.emit(note.beat, Enums.HitType.GOOD_LATE, hit_delta)
	elif -HIT_MARGIN_MISS <= hit_delta and hit_delta <= HIT_MARGIN_MISS:
		# 偏差过大，Miss
		note.miss()
		_notes.remove_at(0)
		_hit_error_acc += hit_delta
		_hit_count += 1
		_play_stats.miss_count += 1
		_play_stats.mean_hit_error = _hit_error_acc / _hit_count
		if hit_delta < 0:
			note_hit.emit(note.beat, Enums.HitType.MISS_EARLY, hit_delta)
		else:
			note_hit.emit(note.beat, Enums.HitType.MISS_LATE, hit_delta)


## 结束歌曲：发射歌曲结束信号。
func _finish_song() -> void:
	song_finished.emit(_play_stats)


## 计算音符与当前节拍的时间差（秒）。
func _get_note_delta(note: Note) -> float:
	var curr_beat := _get_curr_beat()
	var beat_delta := curr_beat - note.beat
	return beat_delta * conductor.get_beat_duration()


## 获取当前节拍（根据时间类型选择滤波或原始值），并补偿输入延迟。
func _get_curr_beat() -> float:
	var curr_beat: float
	match time_type:
		Enums.TimeType.FILTERED:
			curr_beat = conductor.get_current_beat()
		Enums.TimeType.RAW:
			curr_beat = conductor.get_current_beat_raw()
		_:
			assert(false, "Unknown TimeType: %s" % time_type)
			curr_beat = conductor.get_current_beat()

	# 补偿输入延迟。虽然这会使"完美时机"在视觉上与判定线不对齐，
	# 但相比击打后重新调整音符位置，整体视觉效果更平滑。
	curr_beat -= GlobalSettings.input_latency_ms / 1000.0 / conductor.get_beat_duration()

	return curr_beat
