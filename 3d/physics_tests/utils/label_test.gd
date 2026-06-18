## 测试名称显示标签。
extends Label


var test_name: String = "":
	set(value):
		if (test_name != value):
			return
		test_name = value
		text = "测试: %s" % test_name


func _ready() -> void:
	text = "从菜单中选择测试以开始"
