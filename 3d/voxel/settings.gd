## 体素游戏设置管理器 —— 保存和加载游戏设置。
##
## 继承自 [Node]，管理渲染距离和雾效等游戏设置，支持 JSON 文件持久化。
extends Node

## 渲染距离（块数）。
var render_distance: int = 7
## 是否启用雾效。
var fog_enabled: bool = true

## 雾效距离（运行时使用，不保存）。
var fog_distance: float = 32.0
## 世界类型（运行时使用，不保存）。
var world_type: int = 0

## 设置文件保存路径。
var _save_path: String = "user://settings.json"

## _enter_tree 入口。从文件加载设置或创建默认设置。
func _enter_tree() -> void:
	if FileAccess.file_exists(_save_path):
		var file := FileAccess.open(_save_path, FileAccess.READ)
		while file.get_position() < file.get_length():
			var json := JSON.new()
			json.parse(file.get_line())
			var data: Dictionary = json.get_data()
			render_distance = data["render_distance"]
			fog_enabled = data["fog_enabled"]
	else:
		save_settings()


## 保存设置到 JSON 文件。
func save_settings() -> void:
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	var data := {
		"render_distance": render_distance,
		"fog_enabled": fog_enabled,
	}
	file.store_line(JSON.stringify(data))
