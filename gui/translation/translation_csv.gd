## CSV 翻译演示 —— 展示 Godot 的 CSV 翻译系统。
## 继承自 [Panel]，演示如何使用 CSV 文件进行多语言翻译。
## 注意：CSV 格式不支持复数翻译，如需复数支持请使用 PO 格式。
## 更多信息请参考 Godot 文档 "Internationalization"：
## https://docs.godotengine.org/en/latest/tutorials/i18n/index.html
extends Panel


## _ready 入口：调用 _print_intro 输出翻译示例。
func _ready() -> void:
	_print_intro()


## 英语按钮点击回调：切换到英语语言环境。
func _on_english_pressed() -> void:
	TranslationServer.set_locale("en")
	_print_intro()


## 西班牙语按钮点击回调：切换到西班牙语语言环境。
func _on_spanish_pressed() -> void:
	TranslationServer.set_locale("es")
	_print_intro()


## 日语按钮点击回调：切换到日语语言环境。
func _on_japanese_pressed() -> void:
	TranslationServer.set_locale("ja")
	_print_intro()


## 俄语按钮点击回调：切换到俄语语言环境。
func _on_russian_pressed() -> void:
	TranslationServer.set_locale("ru")
	_print_intro()


## 播放音频按钮点击回调：播放 Audio 节点的音频。
func _on_play_audio_pressed() -> void:
	$Audio.play()


## 输出翻译示例到控制台。
## 演示 tr() 函数通过键名获取 CSV 翻译文本。
func _print_intro() -> void:
	print_rich("\n[b]Language:[/b] %s (%s)" % [TranslationServer.get_locale_name(TranslationServer.get_locale()), TranslationServer.get_locale()])

	# CSV 翻译中，使用适当的键名调用 Object.tr() 函数来获取对应的翻译文本。
	# 场景节点中包含用户可见文本时也是同样的方式。
	print(tr(&"KEY_INTRO"))

	# CSV 不支持复数翻译。如果需要复数支持，必须使用 PO 格式。


## 跳转到 PO 翻译演示场景。
func _on_go_to_po_translation_demo_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://translation_demo_po.tscn"))
