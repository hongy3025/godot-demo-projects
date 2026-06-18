## PO 文件翻译演示 —— 展示 Godot 的 gettext PO 翻译系统。
## 继承自 [Panel]，演示如何使用 PO 文件进行多语言翻译（包括复数形式翻译）。
## 更多信息请参考 Godot 文档 "Localization using gettext"：
## https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html
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


## 播放音频按钮点击回调：播放 Audio 节点的音频。
func _on_play_audio_pressed() -> void:
	$Audio.play()


## 输出翻译示例到控制台。
## 演示 tr() 单数翻译和 tr_n() 复数翻译两种方式。
## PO 翻译使用源字符串作为键，复数翻译需要额外传入复数消息参数。
func _print_intro() -> void:
	print_rich("\n[b]Language:[/b] %s (%s)" % [TranslationServer.get_locale_name(TranslationServer.get_locale()), TranslationServer.get_locale()])

	# PO 翻译中，使用源字符串作为 Object.tr() 的"键"。
	# 场景节点中需要翻译的用户可见文本也是同样的方式。
	print(tr(&"Hello, this is a translation demo project."))

	# PO 复数翻译示例。
	# 与 CSV 不同，PO 必须传入 "plural_message" 参数，否则行为未定义。
	var days_passed := randi_range(1, 3)
	print(tr_n(&"One day ago.", &"{days} days ago.", days_passed).format({ days = days_passed }))


## 跳转到 CSV 翻译演示场景。
func _on_go_to_csv_translation_demo_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://translation_demo_csv.tscn"))
