## 日志系统 —— 提供全局日志打印和错误输出功能。
extends Node


enum LogType {
	LOG,
	ERROR,
}

signal entry_logged(message: String, type: LogType)


## 打印日志消息。
func print_log(message: String) -> void:
	print(message)
	entry_logged.emit(message, LogType.LOG)


## 打印错误消息。
func print_error(message: String) -> void:
	push_error(message)
	printerr(message)
	entry_logged.emit(message, LogType.ERROR)
