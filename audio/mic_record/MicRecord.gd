## 麦克风录音演示 —— 录制、播放和保存音频。
##
## 继承自 [Control]，使用 [AudioEffectRecord] 从麦克风录制音频，
## 支持设置采样率、格式（8/16 位、IMA ADPCM）、立体声/单声道，
## 录制后可以播放并保存为 WAV 文件。
extends Control

## 录音效果实例，从"Record"音频总线获取。
var effect: AudioEffect
## 录制的音频数据，保存为 [AudioStreamWAV] 格式。
var recording: AudioStreamWAV

## 是否立体声录制。
var stereo: bool = true
## 采样率（Hz），默认 44100。
var mix_rate := 44100
## 音频格式，默认 16 位。
var format := AudioStreamWAV.FORMAT_16_BITS


func _ready() -> void:
	var idx := AudioServer.get_bus_index(&"Record")
	effect = AudioServer.get_bus_effect(idx, 0)


## 录音按钮点击：开始或停止录音。
func _on_record_button_pressed() -> void:
	if effect.is_recording_active():
		# 停止录音，获取录制数据
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		# 应用用户设置的音频参数
		recording.set_mix_rate(mix_rate)
		recording.set_format(format)
		recording.set_stereo(stereo)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		# 开始录音
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Status: Recording..."


## 播放按钮点击：播放录制的音频并在控制台输出信息。
func _on_play_button_pressed() -> void:
	print_rich("\n[b]Playing recording:[/b] %s" % recording)
	print_rich("[b]Format:[/b] %s" % ("8-bit uncompressed" if recording.format == 0 else "16-bit uncompressed" if recording.format == 1 else "IMA ADPCM compressed"))
	print_rich("[b]Mix rate:[/b] %s Hz" % recording.mix_rate)
	print_rich("[b]Stereo:[/b] %s" % ("Yes" if recording.stereo else "No"))
	var data := recording.get_data()
	print_rich("[b]Size:[/b] %s bytes" % data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()


## 背景音乐播放/停止按钮点击。
func _on_play_music_pressed() -> void:
	if $AudioStreamPlayer2.playing:
		$AudioStreamPlayer2.stop()
		$PlayMusic.text = "Play Music"
	else:
		$AudioStreamPlayer2.play()
		$PlayMusic.text = "Stop Music"


## 保存按钮点击：将录音保存为 WAV 文件。
func _on_save_button_pressed() -> void:
	var save_path: String = $SaveButton/Filename.text
	recording.save_to_wav(save_path)
	$Status.text = "Status: Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]


## 采样率下拉框选择：更新录音采样率。
func _on_mix_rate_option_button_item_selected(index: int) -> void:
	match index:
		0:
			mix_rate = 11025
		1:
			mix_rate = 16000
		2:
			mix_rate = 22050
		3:
			mix_rate = 32000
		4:
			mix_rate = 44100
		5:
			mix_rate = 48000
	if recording != null:
		recording.set_mix_rate(mix_rate)


## 格式下拉框选择：更新录音格式（8 位/16 位/IMA ADPCM）。
func _on_format_option_button_item_selected(index: int) -> void:
	match index:
		0:
			format = AudioStreamWAV.FORMAT_8_BITS
		1:
			format = AudioStreamWAV.FORMAT_16_BITS
		2:
			format = AudioStreamWAV.FORMAT_IMA_ADPCM
	if recording != null:
		recording.set_format(format)


## 立体声复选框切换：更新录音的立体声/单声道设置。
func _on_stereo_check_button_toggled(button_pressed: bool) -> void:
	stereo = button_pressed
	if recording != null:
		recording.set_stereo(stereo)


## 打开用户文件夹按钮点击：在文件管理器中打开 user:// 目录。
func _on_open_user_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))
