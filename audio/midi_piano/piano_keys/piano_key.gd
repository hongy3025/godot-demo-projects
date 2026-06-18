## 钢琴键节点 —— 单个钢琴键的视觉和音频逻辑。
##
## 继承自 [Control]，支持通过 MIDI 输入或鼠标点击触发发声。
## 使用 A440.wav 作为基础采样，通过调整 pitch_scale 实现不同音高。
class_name PianoKey
extends Control

## 音高缩放比，用于调整音频播放的音高。
var pitch_scale: float

## 键的彩色区域引用。
@onready var key: ColorRect = $Key
## 键的初始颜色，用于恢复。
@onready var start_color: Color = key.color
## 颜色恢复计时器。
@onready var color_timer: Timer = $ColorTimer

## 初始化钢琴键：设置名称和音高缩放比。
## pitch_index: MIDI 音符号（69 = A440）
func setup(pitch_index: int) -> void:
	name = "PianoKey" + str(pitch_index)
	var exponent := (pitch_index - 69.0) / 12.0
	pitch_scale = pow(2, exponent)


## 激活钢琴键：改变颜色、播放音效并启动颜色恢复计时器。
func activate() -> void:
	key.color = (Color.YELLOW + start_color) / 2
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = preload("res://piano_keys/A440.wav")
	audio.pitch_scale = pitch_scale
	audio.play()
	color_timer.start()
	await get_tree().create_timer(8.0).timeout
	audio.queue_free()


## 停用钢琴键：恢复键的初始颜色。
func deactivate() -> void:
	key.color = start_color
