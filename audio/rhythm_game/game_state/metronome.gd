## 节拍器 —— 在每个节拍播放提示音。
##
## 继承自 [AudioStreamPlayer]，根据 [Conductor] 提供的节拍信息，
## 在每拍开始时播放节拍音效。
extends AudioStreamPlayer

## 节拍控制器引用。
@export var conductor: Conductor

## 是否正在运行。
var _playing: bool = false
## 上一帧的节拍值（取整后），初始为 -17 以提供 16 拍倒计时。
var _last_beat: float = -17
## 缓存的输出延迟值，避免每帧重复调用。
var _cached_latency: float = AudioServer.get_output_latency()


## 每帧检测节拍变化，在新节拍开始时播放音效。
func _process(_delta: float) -> void:
	if not _playing:
		return

	# 注意：此实现存在缺陷，因为 Godot 的音频混音缓冲区导致每次滴答
	# 都会舍入到下一个混音窗口（默认 44100Hz 混音率下约 11ms）。
	# 精确的音频调度功能已在以下提案中请求：
	# https://github.com/godotengine/godot-proposals/issues/1151
	var curr_beat := conductor.get_current_beat() + _cached_latency
	if GlobalSettings.enable_metronome and floor(curr_beat) > floor(_last_beat):
		play()
	_last_beat = max(_last_beat, curr_beat)


## 启动节拍器。
func start() -> void:
	_playing = true
