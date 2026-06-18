## 拖放演示 —— 展示 Godot 的拖放（Drag & Drop）功能。
## 继承自 [ColorPickerButton]，实现颜色拖放：从一个颜色选择器拖拽颜色到另一个。
extends ColorPickerButton


## 获取拖拽数据。当用户从此控件拖拽离开时调用。
## 同时调用 set_drag_preview() 显示拖拽预览，让用户知道操作正在进行。
##
## 参数:
##   _at_position: 鼠标在控件内的局部位置（未使用）
## 返回: [Color] 当前颜色作为拖拽数据
func _get_drag_data(_at_position: Vector2) -> Color:
	# 使用另一个颜色选择器作为拖拽预览。
	var cpb := ColorPickerButton.new()
	cpb.color = color
	cpb.size = Vector2(80.0, 50.0)

	# 创建一个容器控件来居中颜色选择器在鼠标上。
	var preview := Control.new()
	preview.add_child(cpb)
	cpb.position = -0.5 * cpb.size

	# 设置用户拖拽时看到的预览。
	set_drag_preview(preview)

	# 返回颜色作为拖拽数据。
	return color


## 检查是否可以放置数据。通过验证数据类型来判断是否允许在此处放下。
##
## 参数:
##   _at_position: 鼠标在控件内的局部位置（未使用）
##   data: 被拖拽的数据
## 返回: [bool] 如果数据类型是 Color 则返回 true
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_COLOR


## 处理放置数据。将拖拽过来的颜色赋值给当前颜色选择器。
##
## 参数:
##   _at_position: 鼠标在控件内的局部位置（未使用）
##   data: 被拖拽的数据（Color 类型）
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	color = data
