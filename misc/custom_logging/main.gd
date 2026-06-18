## 自定义日志演示 —— 主控制面板。
##
## 继承自 [Control]，提供按钮触发各种类型的日志输出，
## 演示 print、push_error、push_warning、printerr、printraw 等函数。
extends Control


## 普通消息计数器
var message_counter: int = 0
## 原始消息计数器
var message_raw_counter: int = 0
## stderr 消息计数器
var message_stderr_counter: int = 0
## 警告计数器
var warning_counter: int = 0
## 错误计数器
var error_counter: int = 0


## _ready 入口，输出示例日志消息。
func _ready() -> void:
	print("Normal message 1.")
	push_error("Error 1.")
	push_warning("Warning 1.")
	push_error("Error 2.")
	push_warning("Warning 2.")
	print("Normal message 2.")
	printerr("Normal message 1 (stderr).")
	printerr("Normal message 2 (stderr).")
	printraw("Normal message 1 (raw). ")
	printraw("Normal message 2 (raw).\n--------\n")

	if bool(ProjectSettings.get_setting_with_override(&"application/run/flush_stdout_on_print")):
		$FlushStdoutOnPrint.text = "Flush stdout on print: Yes (?)"
	else:
		$FlushStdoutOnPrint.text = "Flush stdout on print: No (?)"


## 打印普通消息按钮回调。
func _on_print_message_pressed() -> void:
	message_counter += 1
	print("Printing message #%d." % message_counter)


## 打印原始消息按钮回调。
func _on_print_message_raw_pressed() -> void:
	message_raw_counter += 1
	printraw("Printing message #%d (raw). " % message_raw_counter)


## 打印 stderr 消息按钮回调。
func _on_print_message_stderr_pressed() -> void:
	message_stderr_counter += 1
	printerr("Printing message #%d (stderr)." % message_stderr_counter)


## 打印警告按钮回调。
func _on_print_warning_pressed() -> void:
	warning_counter += 1
	push_warning("Printing warning #%d." % warning_counter)


## 打印错误按钮回调。
func _on_print_error_pressed() -> void:
	error_counter += 1
	push_error("Printing error #%d." % error_counter)


## 打开日志文件夹按钮回调。
func _on_open_logs_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(String(ProjectSettings.get_setting_with_override(&"debug/file_logging/log_path")).get_base_dir()))


## 崩溃引擎按钮回调（用于测试崩溃报告）。
func _on_crash_engine_pressed() -> void:
	OS.crash("Crashing the engine on user request (the Crash Engine button was pressed). Do not report this as a bug.")
