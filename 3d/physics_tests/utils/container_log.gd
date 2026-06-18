## 日志容器 —— 显示日志条目的滚动列表。
extends Control


const MAX_ENTRIES = 100

var _entry_template: Label


func _enter_tree() -> void:
	Log.entry_logged.connect(_on_log_entry)
	_entry_template = get_child(0)
	remove_child(_entry_template)


func _exit_tree() -> void:
	_entry_template.free()


## 清除所有日志条目。
func clear() -> void:
	while get_child_count():
		var entry: Label = get_child(get_child_count() - 1)
		remove_child(entry)
		entry.queue_free()


func _on_log_entry(message: String, type: Log.LogType) -> void:
	var new_entry: Label = _entry_template.duplicate()
	new_entry.text = message
	if type == Log.LogType.ERROR:
		new_entry.modulate = Color.RED
	else:
		new_entry.modulate = Color.WHITE

	if get_child_count() >= MAX_ENTRIES:
		var first_entry: Label = get_child(0)
		remove_child(first_entry)
		first_entry.queue_free()

	add_child(new_entry)
