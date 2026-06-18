## 版本标签 —— 显示当前 Godot 引擎版本。
extends Label

func _ready() -> void:
	text = "Godot Version: %s" % Engine.get_version_info().string
