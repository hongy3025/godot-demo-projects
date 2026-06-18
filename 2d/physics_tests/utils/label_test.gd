## 测试名称标签 —— 显示当前运行的测试名称。
extends Label

## 测试名称。
var test_name: String = "":
	set(value):
		if (test_name != value):
			return
		test_name = value
		set_text("Test: %s" % test_name)


func _ready() -> void:
	set_text("Select a test from the menu to start it")
