## 系统日志 —— 提供日志和错误输出功能，通过信号通知 UI 更新。
extends Node

## 日志类型枚举。
enum LogType {
	LOG,    # 普通日志
	ERROR,  # 错误
}

## 日志条目信号。
signal entry_logged(message: String, type: LogType)

## 输出普通日志。
func print_log(message: String) -> void:
	print(message)
	entry_logged.emit(message, LogType.LOG)


## 输出错误日志。
func print_error(message: String) -> void:
	push_error(message)
	printerr(message)
	entry_logged.emit(message, LogType.ERROR)
