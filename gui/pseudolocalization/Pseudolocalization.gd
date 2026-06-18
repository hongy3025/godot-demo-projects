## 伪本地化演示 —— 展示 Godot 的伪本地化（Pseudolocalization）功能。
## 继承自 [Control]，提供 UI 控件来配置和测试伪本地化的各种选项。
## 伪本地化用于在开发阶段模拟翻译效果，帮助发现 UI 布局和文本硬编码问题。
extends Control


## _ready 入口：从项目设置中读取伪本地化配置并同步到 UI 控件。
func _ready() -> void:
	$Main/Pseudolocalization_options/accents.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/replace_with_accents")
	$Main/Pseudolocalization_options/toggle.button_pressed = TranslationServer.pseudolocalization_enabled
	$Main/Pseudolocalization_options/fakebidi.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/fake_bidi")
	$Main/Pseudolocalization_options/doublevowels.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/double_vowels")
	$Main/Pseudolocalization_options/override.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/override")
	$Main/Pseudolocalization_options/skipplaceholders.button_pressed = ProjectSettings.get_setting("internationalization/pseudolocalization/skip_placeholders")
	$Main/Pseudolocalization_options/prefix/TextEdit.text = ProjectSettings.get_setting("internationalization/pseudolocalization/prefix")
	$Main/Pseudolocalization_options/suffix/TextEdit.text = ProjectSettings.get_setting("internationalization/pseudolocalization/suffix")
	$Main/Pseudolocalization_options/exp_ratio/SpinBox.value = float(ProjectSettings.get_setting("internationalization/pseudolocalization/expansion_ratio"))


## 重音替换开关回调：启用/禁用用重音字符替换普通字符。
func _on_accents_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/replace_with_accents", button_pressed)
	TranslationServer.reload_pseudolocalization()


## 伪本地化总开关回调：启用/禁用伪本地化功能。
func _on_toggle_toggled(button_pressed: bool) -> void:
	TranslationServer.pseudolocalization_enabled = button_pressed


## 伪双向文本开关回调：启用/禁用伪造的 BiDi 文本翻转。
func _on_fake_bidi_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/fake_bidi", button_pressed)
	TranslationServer.reload_pseudolocalization()


## 前缀文本变化回调：更新伪本地化文本的前缀。
func _on_prefix_changed(new_text: String) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/prefix", new_text)
	TranslationServer.reload_pseudolocalization()


## 后缀文本变化回调：更新伪本地化文本的后缀。
func _on_suffix_changed(new_text: String) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/suffix", new_text)
	TranslationServer.reload_pseudolocalization()


## 伪本地化按钮点击回调：对输入文本执行伪本地化并显示结果。
func _on_pseudolocalize_pressed() -> void:
	$Main/Pseudolocalizer/Result.text = TranslationServer.pseudolocalize($Main/Pseudolocalizer/Key.text)


## 双元音开关回调：启用/禁用元音重复（模拟文本膨胀）。
func _on_double_vowels_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/double_vowels", button_pressed)
	TranslationServer.reload_pseudolocalization()


## 膨胀比例滑块变化回调：更新文本膨胀比例。
func _on_expansion_ratio_value_changed(value: float) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/expansion_ratio", value)
	TranslationServer.reload_pseudolocalization()


## 覆盖模式开关回调：启用/禁用覆盖已翻译字符串的伪本地化。
func _on_override_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/override", button_pressed)
	TranslationServer.reload_pseudolocalization()


## 跳过占位符开关回调：启用/禁用跳过文本中的占位符（如 %s, {name} 等）。
func _on_skip_placeholders_toggled(button_pressed: bool) -> void:
	ProjectSettings.set_setting("internationalization/pseudolocalization/skip_placeholders", button_pressed)
	TranslationServer.reload_pseudolocalization()
