## 音频输出设备切换器 —— 演示如何在运行时切换音频输出设备。
##
## 继承自 [Control]，列出系统所有可用的音频输出设备，
## 支持切换设备并显示当前设备信息和扬声器模式。
extends Control

## 设备列表控件引用，通过 @onready 在节点就绪时自动获取。
@onready var item_list: ItemList = $ItemList

func _ready() -> void:
	# 遍历所有可用输出设备并添加到列表
	for item in AudioServer.get_output_device_list():
		item_list.add_item(item)

	# 选中当前正在使用的输出设备
	var device := AudioServer.get_output_device()
	for i in item_list.get_item_count():
		if device == item_list.get_item_text(i):
			item_list.select(i)
			break


## 每帧更新设备信息和扬声器模式显示。
func _process(_delta: float) -> void:
	var speaker_mode_text: String = "Stereo"
	var speaker_mode := AudioServer.get_speaker_mode()

	if speaker_mode == AudioServer.SPEAKER_SURROUND_31:
		speaker_mode_text = "Surround 3.1"
	elif speaker_mode == AudioServer.SPEAKER_SURROUND_51:
		speaker_mode_text = "Surround 5.1"
	elif speaker_mode == AudioServer.SPEAKER_SURROUND_71:
		speaker_mode_text = "Surround 7.1"

	$DeviceInfo.text = "Current Device: " + AudioServer.get_output_device() + "\n"
	$DeviceInfo.text += "Speaker Mode: " + speaker_mode_text


## 切换设备按钮点击：将音频输出切换到列表中选中的设备。
func _on_Button_button_down() -> void:
	for item in item_list.get_selected_items():
		var device := item_list.get_item_text(item)
		AudioServer.set_output_device(device)


## 播放/停止音频按钮点击：切换测试音频的播放状态。
func _on_Play_Audio_button_down() -> void:
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
		$PlayAudio.text = "Play Audio"
	else:
		$AudioStreamPlayer.play()
		$PlayAudio.text = "Stop Audio"
