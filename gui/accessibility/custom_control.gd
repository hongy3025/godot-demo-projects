## 自定义无障碍控件 —— 展示 Godot 的无障碍（Accessibility）功能。
## 继承自 [Control]，实现一个包含三个可选项目的自定义列表控件，
## 支持键盘导航、数值调节，并通过无障碍 API 与屏幕阅读器交互。
extends Control

## 三个列表项的无障碍元素 RID 数组。
var item_aes: Array[RID] = [RID(), RID(), RID()]
## 三个列表项的名称。
var item_names: Array[String] = ["Item 1", "Item 2", "Item 3"]
## 三个列表项的当前数值。
var item_values: Array[int] = [0, 0, 0]
## 三个列表项的边界矩形。
var item_rects: Array[Rect2] = [Rect2(0, 0, 40, 40), Rect2(40, 0, 40, 40), Rect2(80, 0, 40, 40)]
## 当前选中的列表项索引。
var selected: int = 0


# 输入处理：

## _gui_input GUI 输入处理：处理键盘方向键导航和数值调节。
## 左/右键切换选中项，上/下键调节当前项的数值。
func _gui_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		selected = (selected - 1) % item_aes.size()
		queue_redraw()
		queue_accessibility_update()
		accept_event()

	if input_event.is_action_pressed(&"ui_right"):
		selected = (selected + 1) % item_aes.size()
		queue_redraw()
		queue_accessibility_update()
		accept_event()

	if input_event.is_action_pressed(&"ui_up"):
		item_values[selected] = clampi(item_values[selected] - 1, -100, 100)
		queue_redraw()
		queue_accessibility_update()
		accept_event()

	if input_event.is_action_pressed(&"ui_down"):
		item_values[selected] = clampi(item_values[selected] + 1, -100, 100)
		queue_redraw()
		queue_accessibility_update()
		accept_event()


# 无障碍操作和焦点回调：

## 数值递减操作回调（供屏幕阅读器调用）。
func _accessibility_action_dec(_data: Variant, item: int) -> void:
	item_values[item] = clampi(item_values[item] - 1, -100, 100)
	queue_redraw()
	queue_accessibility_update()


## 数值递增操作回调（供屏幕阅读器调用）。
func _accessibility_action_inc(_data: Variant, item: int) -> void:
	item_values[item] = clampi(item_values[item] + 1, -100, 100)
	queue_redraw()
	queue_accessibility_update()


## 数值设置操作回调（供屏幕阅读器调用）。
func _accessibility_action_set_num_value(data: Variant, item: int) -> void:
	item_values[item] = clampi(data, -100, 100)
	queue_redraw()
	queue_accessibility_update()


## 获取当前聚焦的无障碍子元素。
## 如果无子元素聚焦，返回基础元素（由 get_accessibility_element 返回的值）。
func _get_focused_accessibility_element() -> RID:
	return item_aes[selected]


# 通知处理：

## 通知处理函数：处理无障碍相关的通知。
##
## NOTIFICATION_ACCESSIBILITY_INVALIDATE: 主元素销毁时的清理。
## NOTIFICATION_ACCESSIBILITY_UPDATE: 更新无障碍信息（类似 _draw 对屏幕阅读器的作用）。
## NOTIFICATION_FOCUS_ENTER / NOTIFICATION_FOCUS_EXIT: 焦点变化时触发重绘。
func _notification(what: int) -> void:
	if what == NOTIFICATION_ACCESSIBILITY_INVALIDATE:
		# 无障碍清理：当主元素被销毁时调用。
		# 注意：子元素是主元素的子级，无需手动销毁，但需要跟踪句柄失效。
		for i in range(item_aes.size()):
			item_aes[i] = RID()

	if what == NOTIFICATION_ACCESSIBILITY_UPDATE:
		# 无障碍更新处理：
		# 此函数作为屏幕阅读器的替代"绘制"方法，提供关于此节点的信息。

		var ae: RID = get_accessibility_element()

		# 设置元素角色为列表框。
		DisplayServer.accessibility_update_set_role(ae, DisplayServer.ROLE_LIST_BOX)

		# 设置其他属性。
		DisplayServer.accessibility_update_set_list_item_count(ae, item_aes.size())
		DisplayServer.accessibility_update_set_name(ae, "List")

		for i in range(item_aes.size()):
			# 如果子元素不存在则创建。
			if not item_aes[i].is_valid():
				item_aes[i] = DisplayServer.accessibility_create_sub_element(ae, DisplayServer.ROLE_LIST_BOX_OPTION)

			# 设置子元素属性。
			DisplayServer.accessibility_update_set_list_item_index(item_aes[i], i)
			DisplayServer.accessibility_update_set_list_item_selected(item_aes[i], selected == i)
			DisplayServer.accessibility_update_set_name(item_aes[i], item_names[i])
			DisplayServer.accessibility_update_set_value(item_aes[i], str(item_values[i]))

			# 数值信息，供数值操作使用。
			DisplayServer.accessibility_update_set_num_value(item_aes[i], item_values[i]);
			DisplayServer.accessibility_update_set_num_range(item_aes[i], -100.0, 100.0);
			DisplayServer.accessibility_update_set_num_step(item_aes[i], 1.0)

			# 子元素边界框，相对于父元素。
			DisplayServer.accessibility_update_set_bounds(item_aes[i], item_rects[i])

			# 设置子元素支持的操作，屏幕阅读器可通过全局快捷键直接调用。
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_DECREMENT, _accessibility_action_dec.bind(i))
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_INCREMENT, _accessibility_action_inc.bind(i))
			DisplayServer.accessibility_update_add_action(item_aes[i], DisplayServer.ACTION_SET_VALUE, _accessibility_action_set_num_value.bind(i))

	if what == NOTIFICATION_FOCUS_ENTER or what == NOTIFICATION_FOCUS_EXIT:
		queue_redraw()


# 绘制：

## _draw 绘制函数：提供视觉反馈，非屏幕阅读器支持所必需。
func _draw() -> void:
	for i in range(item_aes.size()):
		draw_rect(item_rects[selected], Color(0.8, 0.8, 0.8, 0.5), false, 1.0)
		draw_string(get_theme_font(&"font"), item_rects[i].position + Vector2(0, 30), str(item_values[i]), HORIZONTAL_ALIGNMENT_CENTER, 40.0)

	if has_focus():
		draw_rect(Rect2(Vector2(), get_size()), Color(0, 0, 1, 0.5), false, 3.0)
		draw_rect(item_rects[selected], Color(0, 1, 0, 0.5), false, 2.0)
