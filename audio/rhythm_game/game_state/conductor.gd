## 节拍控制器 —— 精确追踪歌曲的当前节拍。
##
## 核心算法：同时使用音频线程时间（精确但抖动大）和系统时钟时间（稳定但可能漂移），
## 通过 1€ 滤波器对两者的差值进行平滑，综合两种时间源的优点。
class_name Conductor
extends Node

## 是否暂停。设置 [code]true[/code] 暂停歌曲，[code]false[/code] 恢复。
@export var is_paused: bool = false:
	get:
		if player:
			return player.stream_paused
		return false
	set(value):
		if player:
			player.stream_paused = value

@export_group("Nodes")
## 音频播放器节点引用。
@export var player: AudioStreamPlayer

@export_group("Song Parameters")
## 歌曲的 BPM（每分钟节拍数）。
@export var bpm: float = 100
## 第一拍在音频文件中的偏移量（毫秒）。
## 例如 5000 表示第一拍在音频的第 5 秒处。
@export var first_beat_offset_ms: int = 0

@export_group("Filter Parameters")
## 1€ 滤波器的截止频率参数。减小此值可减少抖动。
@export var allowed_jitter: float = 0.1
## 1€ 滤波器的 beta 参数。增大此值可减少延迟。
@export var lag_reduction: float = 5

## 缓存的输出延迟值。此值在运行中不会改变，因此缓存以避免重复调用。
var _cached_output_latency: float = AudioServer.get_output_latency()

## 是否正在播放。
var _is_playing: bool = false

## 基于音频线程的歌曲时间（抖动但精确）。
var _song_time_audio: float = -100

## 基于系统时钟的歌曲开始时间戳。
var _song_time_begin: float = 0
## 基于系统时钟的歌曲时间（稳定但可能漂移）。
var _song_time_system: float = -100

## 1€ 滤波器实例，用于平滑音频时间和系统时间的差值。
var _filter: OneEuroFilter
## 滤波后的音频-系统时间差值。
var _filtered_audio_system_delta: float = 0


func _ready() -> void:
	# 确保播放状态始终更新，否则平滑滤波器会出现问题
	process_mode = Node.PROCESS_MODE_ALWAYS


## 每帧更新音频时间和系统时间。
func _process(_delta: float) -> void:
	if not _is_playing:
		return

	# 处理 Web 平台的 bug：AudioServer.get_time_since_last_mix() 偶尔返回
	# 无符号 64 位整数的最大值。这可能是主线程和音频线程之间的时序问题
	# 导致引擎代码中出现下溢。
	var last_mix := AudioServer.get_time_since_last_mix()
	if last_mix > 1000:
		last_mix = 0

	# 首先使用音频线程数据计算歌曲时间。此值抖动较大，但始终与玩家听到的音频一致。
	_song_time_audio = (
			player.get_playback_position()
			# 第一拍可能不在音频的第 0 秒处，用偏移量补偿
			- first_beat_offset_ms / 1000.0
			# 大多数平台上，播放位置值以"混音"块为单位更新，
			# 加上自上次混音块处理以来的时间使值更平滑
			+ last_mix
			# 当前处理的音频要稍后才能听到
			- _cached_output_latency
		)

	# 然后使用系统时钟以渲染帧率计算歌曲时间。此值非常稳定，
	# 但由于暂停、卡顿等原因可能与实际音频产生漂移。
	_song_time_system = (Time.get_ticks_usec() / 1000000.0) - _song_time_begin
	_song_time_system *= player.pitch_scale

	# 其余工作在 _physics_process 中完成


## 在物理帧中应用 1€ 滤波器平滑音频时间和系统时间的差值。
func _physics_process(delta: float) -> void:
	if not _is_playing:
		return

	# 为了同时获得音频时间（精确）和系统时间（稳定）的优点，
	# 我们对两者差值的 delta 应用平滑滤波器（1€ 滤波器），
	# 然后将滤波后的差值加到系统时间上。
	#
	# 注意：
	# - 1€ 滤波器对变化不剧烈的值效果更好，因此我们对 delta 进行滤波
	#   （帧间变化较小），而不是直接对时间值滤波。
	# - 在 _physics_process 中运行滤波步骤以降低不同系统更新率的变化。
	#   滤波器参数专门针对 60 UPS 调优。
	var audio_system_delta := _song_time_audio - _song_time_system
	_filtered_audio_system_delta = _filter.filter(audio_system_delta, delta)

	# 取消注释以下代码可查看原始时间和滤波后时间的差异
	#var song_time := _song_time_system + _filtered_audio_system_delta
	#print("Error: %+.1f ms" % [abs(song_time - _song_time_audio) * 1000.0])


## 开始播放歌曲并初始化滤波器。
func play() -> void:
	var filter_args := {
		"cutoff": allowed_jitter,
		"beta": lag_reduction,
	}
	_filter = OneEuroFilter.new(filter_args)

	player.play()
	_is_playing = true

	# 使用系统时钟捕获歌曲开始时间
	_song_time_begin = (
			Time.get_ticks_usec() / 1000000.0
			# 第一拍可能不在音频的第 0 秒处，用偏移量补偿
			+ first_beat_offset_ms / 1000.0
			# 播放不会立即开始，而是在下一个音频块被处理时（"混音"步骤）
			# 加上到那时的时间
			+ AudioServer.get_time_to_next_mix()
			# 加上额外的输出延迟
			+ _cached_output_latency
		)


## 停止播放。
func stop() -> void:
	player.stop()
	_is_playing = false


## 返回歌曲的当前节拍（经过平滑滤波）。
func get_current_beat() -> float:
	var song_time := _song_time_system + _filtered_audio_system_delta
	return song_time / get_beat_duration()


## 返回歌曲的当前节拍（未经平滑的原始值）。
func get_current_beat_raw() -> float:
	return _song_time_audio / get_beat_duration()


## 返回一拍的时间长度（秒）。
func get_beat_duration() -> float:
	return 60 / bpm
