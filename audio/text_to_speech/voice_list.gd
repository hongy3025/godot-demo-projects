## 语音列表 —— 文本转语音（TTS）演示界面。
##
## 继承自 [Control]，展示系统可用的 TTS 语音列表，支持语音筛选、
## 多语言朗读、语速/音调/音量调节，以及朗读进度高亮显示。
## 使用 [DisplayServer] 的 TTS API 实现跨平台语音合成。
extends Control

## 朗读片段的自增 ID，用于追踪每次朗读请求。
var id := 0

## 朗读片段 ID 到文本内容的映射，用于回调中定位当前朗读的文本。
var ut_map := {}
## 系统可用语音列表，从 DisplayServer.tts_get_voices() 获取。
var vs: Array[Dictionary]

func _ready() -> void:
	# 获取系统语音数据
	vs = DisplayServer.tts_get_voices()
	var root: TreeItem = $Tree.create_item()
	$Tree.set_hide_root(true)
	$Tree.set_column_title(0, "Name")
	$Tree.set_column_title(1, "Language")
	$Tree.set_column_titles_visible(true)
	for v in vs:
		var child: TreeItem = $Tree.create_item(root)
		child.set_text(0, v["name"])
		child.set_metadata(0, v["id"])
		child.set_text(1, v["language"])
	$Log.text += "%d voices available.\n" % [vs.size()]
	$Log.text += "=======\n"

	# 默认选中列表中的第一个语音
	$Tree.get_root().get_child(0).select(0)

	# 注册 TTS 回调函数
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_STARTED, _on_utterance_start)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _on_utterance_end)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_CANCELED, _on_utterance_error)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_BOUNDARY, _on_utterance_boundary)


## 每帧更新暂停按钮状态和朗读指示色块。
func _process(_delta: float) -> void:
	$ButtonPause.button_pressed = DisplayServer.tts_is_paused()
	if DisplayServer.tts_is_speaking():
		$ColorRect.color = Color(0.9, 0.3, 0.1)
	else:
		$ColorRect.color = Color(1, 1, 1)


## 朗读边界回调：当朗读到达文本中的某个位置时触发，高亮当前已读部分。
## pos: 当前朗读到的字符位置
## ut_id: 朗读片段 ID
func _on_utterance_boundary(pos: int, ut_id: int) -> void:
	$RichTextLabel.text = "[bgcolor=yellow][color=black]" + ut_map[ut_id].substr(0, pos) + "[/color][/bgcolor]" + ut_map[ut_id].substr(pos, -1)


## 朗读开始回调：记录朗读开始日志。
func _on_utterance_start(ut_id: int) -> void:
	$Log.text += "Utterance %d started.\n" % [ut_id]


## 朗读结束回调：高亮完整文本并记录日志，清理映射。
func _on_utterance_end(ut_id: int) -> void:
	$RichTextLabel.text = "[bgcolor=yellow][color=black]" + ut_map[ut_id] + "[/color][/bgcolor]"
	$Log.text += "Utterance %d ended.\n" % [ut_id]
	ut_map.erase(ut_id)


## 朗读错误/取消回调：清空高亮并记录日志，清理映射。
func _on_utterance_error(ut_id: int) -> void:
	$RichTextLabel.text = ""
	$Log.text += "Utterance %d canceled/failed.\n" % [ut_id]
	ut_map.erase(ut_id)


## 停止按钮点击：停止所有朗读。
func _on_button_stop_pressed() -> void:
	DisplayServer.tts_stop()


## 暂停按钮点击：切换暂停/恢复朗读状态。
func _on_button_pause_pressed() -> void:
	if $ButtonPause.pressed:
		DisplayServer.tts_pause()
	else:
		DisplayServer.tts_resume()


## 朗读按钮点击：使用选中的语音朗读输入框中的文本。
func _on_button_speak_pressed() -> void:
	if $Tree.get_selected():
		$Log.text += "Utterance %d queried.\n" % [id]
		ut_map[id] = $Utterance.text
		DisplayServer.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, false)
		id += 1
	else:
		OS.alert("No voice selected.\nSelect a voice in the list, then try using Speak again.")


## 中断朗读按钮点击：中断当前朗读并立即朗读新文本。
func _on_button_int_speak_pressed() -> void:
	if $Tree.get_selected():
		$Log.text += "Utterance %d interrupted.\n" % [id]
		ut_map[id] = $Utterance.text
		DisplayServer.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, true)
		id += 1
	else:
		OS.alert("No voice selected.\nSelect a voice in the list, then try using Interrupt again.")


## 清除日志按钮点击：清空日志文本框。
func _on_button_clear_log_pressed() -> void:
	$Log.text = ""


## 语速滑块值变化：更新语速显示标签。
func _on_HSliderRate_value_changed(value: float) -> void:
	$HSliderRate/Value.text = "%.2fx" % value


## 音调滑块值变化：更新音调显示标签。
func _on_HSliderPitch_value_changed(value: float) -> void:
	$HSliderPitch/Value.text = "%.2fx" % value


## 音量滑块值变化：更新音量显示标签。
func _on_HSliderVolume_value_changed(value: float) -> void:
	$HSliderVolume/Value.text = "%d%%" % value


## 演示按钮点击：使用英语、西班牙语、俄语依次朗读 Jabberwocky 诗歌片段。
func _on_Button_pressed() -> void:
	var vc: PackedStringArray
	# 演示 - 英语
	vc = DisplayServer.tts_get_voices_for_language("en")
	if not vc.is_empty():
		ut_map[id] = "Beware the Jabberwock, my son!"
		ut_map[id + 1] = "The jaws that bite, the claws that catch!"
		DisplayServer.tts_speak("Beware the Jabberwock, my son!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("The jaws that bite, the claws that catch!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2
	# 演示 - 西班牙语
	vc = DisplayServer.tts_get_voices_for_language("es")
	if not vc.is_empty():
		ut_map[id] = "¡Cuidado, hijo, con el Fablistanón!"
		ut_map[id + 1] = "¡Con sus dientes y garras, muerde, apresa!"
		DisplayServer.tts_speak("¡Cuidado, hijo, con el Fablistanón!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("¡Con sus dientes y garras, muerde, apresa!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2
	# 演示 - 俄语
	vc = DisplayServer.tts_get_voices_for_language("ru")
	if not vc.is_empty():
		ut_map[id] = "О, бойся Бармаглота, сын!"
		ut_map[id + 1] = "Он так свирлеп и дик!"
		DisplayServer.tts_speak("О, бойся Бармаглота, сын!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id)
		DisplayServer.tts_speak("Он так свирлеп и дик!", vc[0], $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id + 1)
		id += 2


## 名称筛选输入框文本变化：根据名称和语言筛选语音列表。
func _on_LineEditFilterName_text_changed(_new_text: String) -> void:
	$Tree.clear()
	var root: TreeItem = $Tree.create_item()
	for v in vs:
		if (
				$LineEditFilterName.text.is_empty() or $LineEditFilterName.text.to_lower() in v["name"].to_lower()
		) and (
				$LineEditFilterLang.text.is_empty() or $LineEditFilterLang.text.to_lower() in v["language"].to_lower()
		):
			var child: TreeItem = $Tree.create_item(root)
			child.set_text(0, v["name"])
			child.set_metadata(0, v["id"])
			child.set_text(1, v["language"])
