## 自定义日志 UI —— 将引擎日志重定向到 RichTextLabel 显示。
##
## 继承自 [RichTextLabel]，通过自定义 Logger 捕获引擎的日志消息和错误，
## 在 UI 中以富文本格式显示，支持不同错误类型的颜色区分。
extends RichTextLabel

## 自定义日志记录器实例
var logger := CustomLogger.new()


## 自定义日志记录器类，继承自 [Logger]。
## 必须保证线程安全，因为可能从非主线程调用。
## 使用 call_deferred() 确保节点方法在主线程调用。
class CustomLogger extends Logger:
	## 日志消息回调，将消息追加到 RichTextLabel。
	func _log_message(message: String, _error: bool) -> void:
		CustomLoggerUI.get_node(^"Panel/RichTextLabel").call_deferred(&"append_text", message)


	## 错误消息回调，格式化并显示错误/警告/脚本错误/着色器错误。
	func _log_error(
			function: String,
			file: String,
			line: int,
			code: String,
			rationale: String,
			_editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]
	) -> void:
		var prefix: String = ""
		# 回溯打印的缩进列，应与上方未格式化文本长度匹配
		var trace_indent := 0

		match error_type:
			ERROR_TYPE_ERROR:
				prefix = "[color=#f54][b]ERROR:[/b]"
				trace_indent = 6
			ERROR_TYPE_WARNING:
				prefix = "[color=#fd4][b]WARNING:[/b]"
				trace_indent = 8
			ERROR_TYPE_SCRIPT:
				prefix = "[color=#f4f][b]SCRIPT ERROR:[/b]"
				trace_indent = 13
			ERROR_TYPE_SHADER:
				prefix = "[color=#4bf][b]SHADER ERROR:[/b]"
				trace_indent = 13

		var trace: String = "%*s %s (%s:%s)" % [trace_indent, "at:", function, file, line]
		var script_backtraces_text: String = ""
		for backtrace in script_backtraces:
			script_backtraces_text += backtrace.format(trace_indent - 3) + "\n"

		CustomLoggerUI.get_node(^"Panel/RichTextLabel").call_deferred(
				&"append_text",
				"%s %s %s[/color]\n[color=#999]%s[/color]\n[color=#999]%s[/color]" % [
						prefix,
						code,
						rationale,
						trace,
						script_backtraces_text,
					]
			)


## 使用 _init() 尽早注册日志记录器，确保早期消息也能被捕获。
## 但即使使用 _init()，引擎自身的初始化消息仍不可访问。
func _init() -> void:
	OS.add_logger(logger)


## 移除日志记录器在项目退出时自动完成。
## 如需提前移除可使用 OS.remove_logger()。
## 这也可以避免退出时可能打印的对象泄漏警告。
func _exit_tree() -> void:
	OS.remove_logger(logger)
