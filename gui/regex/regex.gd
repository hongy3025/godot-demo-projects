## 正则表达式演示 —— 展示 Godot 的 RegEx 正则表达式功能。
## 继承自 [VBoxContainer]，提供交互式正则表达式测试界面。
extends VBoxContainer

## 编译后的正则表达式对象。
var regex := RegEx.new()


## _ready 入口：设置默认测试文本并执行初始正则匹配。
func _ready() -> void:
	%Text.set_text("They asked me \"What's going on \\\"in the manor\\\"?\"")
	update_expression(%Expression.text)


## 更新正则表达式：编译用户输入的正则模式并刷新匹配结果。
func update_expression(text: String) -> void:
	regex.compile(text)
	update_text()


## 更新匹配结果展示：清除旧结果，显示所有匹配项及其捕获组。
## 如果正则无效，显示错误提示。
func update_text() -> void:
	for child in %List.get_children():
		child.queue_free()

	if regex.is_valid():
		$HBoxContainer.modulate = Color.WHITE
		var matches := regex.search_all(%Text.get_text())
		if matches.size() >= 1:
			var match_number := 0
			for regex_match in matches:
				match_number += 1
				var match_label := Label.new()
				match_label.text = "RegEx match #%d:" % match_number
				match_label.modulate = Color(0.6, 0.9, 1.0)
				%List.add_child(match_label)

				var capture_number := 0
				for result in regex_match.get_strings():
					capture_number += 1
					var capture_label := Label.new()
					capture_label.text = "    Capture group #%d: %s" % [capture_number, result]
					%List.add_child(capture_label)
	else:
		$HBoxContainer.modulate = Color(1, 0.2, 0.1)
		var label := Label.new()
		label.text = "Error: Invalid regular expression. Check if the expression is correctly escaped and terminated."
		%List.add_child(label)


## 帮助链接点击回调：在系统浏览器中打开 regexr.com 在线正则工具。
func _on_help_meta_clicked(_meta: Variant) -> void:
	OS.shell_open("https://regexr.com")
