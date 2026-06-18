## 音频效果演示 —— 展示 Godot 内置音频效果的开/关控制。
##
## 继承自 [Control]，通过开关按钮控制主音频总线（索引 0）上的
## 18 种内置音频效果（放大、限带、合唱、压缩器、延迟、失真等）。
extends Control


## 音乐开关切换：播放或停止背景音乐。
func _on_toggle_music_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$SoundEffects/Music.play()
	else:
		$SoundEffects/Music.stop()


## 叮咚音效按钮点击。
func _on_ding_button_pressed() -> void:
	$SoundEffects/Ding.play()


## 玻璃破碎音效按钮点击。
func _on_glass_button_pressed() -> void:
	$SoundEffects/Glass.play()


## 猫叫音效按钮点击。
func _on_meow_button_pressed() -> void:
	$SoundEffects/Meow.play()


## 哔哔音效按钮点击。
func _on_beeps_button_pressed() -> void:
	$SoundEffects/Beeps.play()


## 长号音效按钮点击。
func _on_trombone_button_pressed() -> void:
	$SoundEffects/Trombone.play()


## 静电音效按钮点击。
func _on_static_button_pressed() -> void:
	$SoundEffects/Static.play()


## 口哨音效按钮点击。
func _on_whistle_button_pressed() -> void:
	$SoundEffects/Whistle.play()


## 放大效果开关：切换总线 0 上的效果 0（Amplify）。
func _on_toggle_amplify_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 0, button_pressed)


## 限带效果开关：切换总线 0 上的效果 1（BandLimit）。
func _on_toggle_band_limiter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 1, button_pressed)


## 带通滤波器开关：切换总线 0 上的效果 2（BandPass）。
func _on_toggle_band_pass_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 2, button_pressed)


## 合唱效果开关：切换总线 0 上的效果 3（Chorus）。
func _on_toggle_chorus_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 3, button_pressed)


## 压缩器开关：切换总线 0 上的效果 4（Compressor）。
func _on_toggle_compressor_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 4, button_pressed)


## 延迟效果开关：切换总线 0 上的效果 5（Delay）。
func _on_toggle_delay_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 5, button_pressed)


## 失真效果开关：切换总线 0 上的效果 6（Distortion）。
func _on_toggle_distortion_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 6, button_pressed)


## 6 段均衡器开关：切换总线 0 上的效果 7（EQ6）。
func _on_toggle_eq_6_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 7, button_pressed)


## 10 段均衡器开关：切换总线 0 上的效果 8（EQ10）。
func _on_toggle_eq_10_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 8, button_pressed)


## 21 段均衡器开关：切换总线 0 上的效果 9（EQ21）。
func _on_toggle_eq_21_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 9, button_pressed)


## 高通滤波器开关：切换总线 0 上的效果 10（HighPassFilter）。
func _on_toggle_high_pass_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 10, button_pressed)


## 低架滤波器开关：切换总线 0 上的效果 11（LowShelfFilter）。
func _on_toggle_low_shelf_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 11, button_pressed)


## 陷波滤波器开关：切换总线 0 上的效果 12（NotchFilter）。
func _on_toggle_notch_filter_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 12, button_pressed)


## 声像调节器开关：切换总线 0 上的效果 13（Panner）。
func _on_toggle_panner_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 13, button_pressed)


## 移相效果开关：切换总线 0 上的效果 14（Phaser）。
func _on_toggle_phaser_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 14, button_pressed)


## 音高偏移开关：切换总线 0 上的效果 15（PitchShift）。
func _on_toggle_pitch_shift_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 15, button_pressed)


## 混响效果开关：切换总线 0 上的效果 16（Reverb）。
func _on_toggle_reverb_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 16, button_pressed)


## 立体声增强开关：切换总线 0 上的效果 17（StereoEnhance）。
func _on_toggle_stereo_enhance_toggled(button_pressed: bool) -> void:
		AudioServer.set_bus_effect_enabled(0, 17, button_pressed)
