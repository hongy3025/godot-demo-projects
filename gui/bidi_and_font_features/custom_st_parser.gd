## 自定义结构化文本解析器 —— 演示 Godot 的自定义文本方向解析功能。
## 继承自 [LineEdit]，实现一个简单的结构化文本解析器，
## 将冒号分隔的文本段分别设置不同的文本方向。
extends LineEdit


## 结构化文本解析回调。被 Godot 引擎调用，用于解析文本的方向信息。
##
## 功能：将输入文本按冒号分割，为每个分割段及其后的分隔符分别设置 DIRECTION_AUTO，
## 并将结果以逆序方式存入数组。
##
## 参数:
##   _args: 解析参数（未使用）
##   p_text: 需要解析的原始文本
## 返回: [Array[Vector3i]] 每个 Vector3i 包含 (起始位置, 结束位置, 文本方向)
func _structured_text_parser(_args: Variant, p_text: String) -> Array:
	var output: Array[Vector3i] = []
	# 按冒号分割文本
	var tags := p_text.split(":")
	var prev := 0
	var count := tags.size()
	output.clear()

	for i in count:
		# 第一个范围：当前分割段的文本范围，方向自动检测
		var range1 := Vector3i(prev, prev + tags[i].length(), TextServer.DIRECTION_AUTO)
		# 第二个范围：冒号分隔符本身的范围，方向自动检测
		var range2 := Vector3i(prev + tags[i].length(), prev + tags[i].length() + 1, TextServer.DIRECTION_AUTO)
		# 使用 push_front 逆序插入，使结果数组按文本顺序排列
		output.push_front(range1)
		output.push_front(range2)
		prev = prev + tags[i].length() + 1

	return output
