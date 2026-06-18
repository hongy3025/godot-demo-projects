## 音频生成演示 —— 使用 GDScript 实时生成正弦波音频。
##
## 该节点通过 [AudioStreamPlayer] 的 [AudioStreamPlayback] 接口，
## 在 _process 中每帧向音频缓冲区推送采样数据，实现程序化音频生成。
## 演示了 Godot 中动态生成音频流的核心机制。
extends Node

## 采样率（Hz）。每秒混合的采样数，GDScript 性能有限，不宜设置过高。
var sample_hz := 22050.0
## 脉冲频率（Hz）。生成的正弦波频率，默认 440Hz（标准 A4 音）。
var pulse_hz := 440.0
## 当前相位（0.0 ~ 1.0）。用于追踪正弦波在周期中的位置。
var phase := 0.0

## 实际播放流对象，在 _ready() 中赋值。
var playback: AudioStreamPlayback

## 填充音频缓冲区：计算当前帧需要填充的采样数，将正弦波采样推入播放流。
func _fill_buffer() -> void:
	# 计算每采样点的相位增量
	var increment := pulse_hz / sample_hz

	# 获取播放流中可写入的帧数
	var to_fill: int = playback.get_frames_available()
	while to_fill > 0:
		# 音频帧是立体声的，使用 Vector2.ONE 使左右声道相同
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		# 相位累加并限制在 [0, 1) 范围内
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1


## 每帧调用 _fill_buffer 持续填充音频数据。
func _process(_delta: float) -> void:
	_fill_buffer()


## 节点就绪时初始化音频播放。
func _ready() -> void:
	# 设置混音率必须在 play() 之前完成
	$Player.stream.mix_rate = sample_hz
	$Player.play()
	playback = $Player.get_stream_playback()
	# _fill_buffer 必须在 playback 赋值之后调用
	_fill_buffer()


## 频率滑块值变化时的回调。更新脉冲频率和显示标签。
func _on_frequency_h_slider_value_changed(value: float) -> void:
	%FrequencyLabel.text = "%d Hz" % value
	pulse_hz = value


## 音量滑块值变化时的回调。使用 linear_to_db() 转换为人耳感知的线性音量。
func _on_volume_h_slider_value_changed(value: float) -> void:
	%VolumeLabel.text = "%.2f dB" % linear_to_db(value)
	$Player.volume_db = linear_to_db(value)
