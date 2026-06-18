## 钢琴主控脚本 —— 生成完整的钢琴键盘并处理 MIDI 输入。
##
## 继承自 [Control]，根据起始和结束 MIDI 音符号动态生成白键和黑键，
## 支持 MIDI 输入设备和鼠标点击两种交互方式。
extends Control

# 标准 88 键钢琴的音符范围是 21 到 108。
# 修改以下数字可获得不同的键盘范围。
# 108 键扩展钢琴为 12 到 119。
# 76 键钢琴为 23 到 98，61 键为 36 到 96，
# 49 键为 36 到 84，37 键为 41 到 77，25 键为 48 到 72。
# 中央 C 是音符号 60，A440 是 69。
## 起始 MIDI 音符号。
const START_KEY = 21
## 结束 MIDI 音符号。
const END_KEY = 108

## 白键场景预加载。
const WhiteKeyScene := preload("res://piano_keys/white_piano_key.tscn")
## 黑键场景预加载。
const BlackKeyScene := preload("res://piano_keys/black_piano_key.tscn")

## 音符号到钢琴键节点的映射字典。
var piano_key_dict := Dictionary()

## 白键容器引用。
@onready var white_keys: HBoxContainer = $WhiteKeys
## 黑键容器引用。
@onready var black_keys: HBoxContainer = $BlackKeys

func _ready() -> void:
	# 起始键不能是升号键（此钢琴生成算法的限制）
	assert(not _is_note_index_sharp(_pitch_index_to_note_index(START_KEY)), "The start key can't be a sharp note (limitation of this piano-generating algorithm). Try 21.")

	# 生成指定范围内的所有钢琴键
	for i in range(START_KEY, END_KEY + 1):
		piano_key_dict[i] = _create_piano_key(i)

	# 如果黑白键数量不一致，添加占位键
	if white_keys.get_child_count() != black_keys.get_child_count():
		_add_placeholder_key(black_keys)

	# 打开 MIDI 输入
	OS.open_midi_inputs()

	if not OS.get_connected_midi_inputs().is_empty():
		print(OS.get_connected_midi_inputs())


## 处理输入事件：接收 MIDI 输入并映射到对应的钢琴键。
func _input(input_event: InputEvent) -> void:
	if input_event is not InputEventMIDI:
		return

	var midi_event: InputEventMIDI = input_event
	if midi_event.pitch < START_KEY or midi_event.pitch > END_KEY:
		# 音高不在当前键盘范围内，忽略
		return

	_print_midi_info(midi_event)
	var key: PianoKey = piano_key_dict[midi_event.pitch]
	if midi_event.message == MIDI_MESSAGE_NOTE_ON:
		key.activate()
	else:
		key.deactivate()


## 在指定容器中添加占位键，用于对齐黑白键布局。
func _add_placeholder_key(container: HBoxContainer) -> void:
	var placeholder := Control.new()
	placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder.name = &"Placeholder"
	container.add_child(placeholder)


## 创建单个钢琴键（白键或黑键）并添加到对应容器。
## pitch_index: MIDI 音符号
## 返回: 创建的 PianoKey 实例
func _create_piano_key(pitch_index: int) -> PianoKey:
	var note_index := _pitch_index_to_note_index(pitch_index)
	var piano_key: PianoKey
	if _is_note_index_sharp(note_index):
		piano_key = BlackKeyScene.instantiate()
		black_keys.add_child(piano_key)
	else:
		piano_key = WhiteKeyScene.instantiate()
		white_keys.add_child(piano_key)
		if _is_note_index_lacking_sharp(note_index):
			_add_placeholder_key(black_keys)
	piano_key.setup(pitch_index)
	return piano_key


## 判断音名索引是否缺少升号键（B 和 E，因为没有 B# 和 E#）。
func _is_note_index_lacking_sharp(note_index: int) -> bool:
	return note_index in [2, 7]


## 判断音名索引是否为升号（A#, C#, D#, F#, G#）。
func _is_note_index_sharp(note_index: int) -> bool:
	return note_index in [1, 4, 6, 9, 11]


## 将 MIDI 音符号转换为音名索引（0-11，C=0, C#=1, ..., B=11）。
func _pitch_index_to_note_index(pitch: int) -> int:
	pitch += 3
	return pitch % 12


## 在控制台打印 MIDI 事件的详细信息。
func _print_midi_info(midi_event: InputEventMIDI) -> void:
	print(midi_event)
	print("Channel: " + str(midi_event.channel))
	print("Message: " + str(midi_event.message))
	print("Pitch: " + str(midi_event.pitch))
	print("Velocity: " + str(midi_event.velocity))
	print("Instrument: " + str(midi_event.instrument))
	print("Pressure: " + str(midi_event.pressure))
	print("Controller number: " + str(midi_event.controller_number))
	print("Controller value: " + str(midi_event.controller_value))
