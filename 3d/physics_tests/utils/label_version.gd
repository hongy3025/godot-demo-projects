## Godot 版本显示标签。
extends Label


func _process(_delta: float) -> void:
	set_text("Godot 版本: %s" % Engine.get_version_info().string)
