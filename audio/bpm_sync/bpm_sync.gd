## BPM 同步演示 —— 展示两种节拍同步方式。
##
## 继承自 [Panel]，演示如何将节拍与音乐同步。
## 支持两种同步源：系统时钟（SYSTEM_CLOCK）和音频时钟（SOUND_CLOCK）。
extends Panel

## 同步源枚举：系统时钟或音频时钟。
enum SyncSource {
	SYSTEM_CLOCK,
	SOUND_CLOCK,
}

## 每分钟节拍数（BPM）。
const BPM = 116
## 每小节的拍数。
const BARS = 4

## 音频时钟补偿帧数。
const COMPENSATE_FRAMES = 2
## 补偿参考帧率。
const COMPENSATE_HZ = 60.0

## 是否正在播放。
var playing: bool = false
## 当前使用的同步源。
var sync_source := SyncSource.SYSTEM_CLOCK

## 系统时钟模式：开始播放时的系统时间戳（微秒）。
var time_begin: float
## 系统时钟模式：音频延迟补偿值。
var time_delay: float


## 每帧计算当前节拍和时间并更新显示。
func _process(_delta: float) -> void:
	if not playing or not $Player.playing:
		return

	var time := 0.0
	if sync_source == SyncSource.SYSTEM_CLOCK:
		# 从系统时钟获取时间
		time = (Time.get_ticks_usec() - time_begin) / 1000000.0
		# 补偿音频延迟
		time -= time_delay
	elif sync_source == SyncSource.SOUND_CLOCK:
		# 从音频播放位置获取时间，补偿混音延迟和输出延迟
		time = $Player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES

	# 计算当前节拍序号
	var beat := int(time * BPM / 60.0)
	# 计算当前时间（秒）
	var seconds := int(time)
	# 计算音频总时长（秒）
	var seconds_total := int($Player.stream.get_length())
	@warning_ignore("integer_division")
	$Label.text = str("BEAT: ", beat % BARS + 1, "/", BARS, " TIME: ", seconds / 60, ":", str(seconds % 60).pad_zeros(2), " / ", seconds_total / 60, ":", str(seconds_total % 60).pad_zeros(2))


## 系统时钟模式按钮：使用系统时钟作为同步源开始播放。
func _on_PlaySystem_pressed() -> void:
	sync_source = SyncSource.SYSTEM_CLOCK
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	playing = true
	$Player.play()


## 音频时钟模式按钮：使用音频播放位置作为同步源开始播放。
func _on_PlaySound_pressed() -> void:
	sync_source = SyncSource.SOUND_CLOCK
	playing = true
	$Player.play()
