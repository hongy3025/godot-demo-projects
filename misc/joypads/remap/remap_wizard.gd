## 手柄重映射向导 —— 交互式手柄按键映射工具。
##
## 继承自 [Node]，引导用户逐步映射手柄的每个按键和摇杆。
## 支持全轴/半轴映射、轴反转、跳过未映射按键等功能。
## 最终生成 SDL2 格式的映射字符串。
extends Node


## 摇杆死区阈值
const DEADZONE = 0.3

## 当前手柄索引
var joy_index: int = -1
## 当前手柄 GUID
var joy_guid: String = ""
## 当前手柄名称
var joy_name: String = ""

## 需要映射的按键列表（来自 JoyMapping.BASE）
var steps: Array = JoyMapping.BASE.keys()
## 当前步骤索引
var cur_step: int = -1
## 当前映射字典
var cur_mapping: Dictionary = {}
## 最后生成的映射字符串
var last_mapping: String = ""

@onready var joy_buttons: Node2D = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Buttons
@onready var joy_axes: Node2D = $Mapping/Margin/VBox/SubViewportContainer/SubViewport/JoypadDiagram/Axes
@onready var joy_mapping_text: Label = $Mapping/Margin/VBox/Info/Text/Value
@onready var joy_mapping_full_axis: CheckBox = $Mapping/Margin/VBox/Info/Extra/FullAxis
@onready var joy_mapping_axis_invert: CheckBox = $Mapping/Margin/VBox/Info/Extra/InvertAxis


## _input 入口，接收手柄输入事件进行映射。
## 连接到 Mapping.window_input，否则子窗口聚焦时无法接收手柄事件。
func _input(input_event: InputEvent) -> void:
	if cur_step == -1:
		return

	# 忽略非手柄事件
	if input_event is not InputEventJoypadButton and input_event is not InputEventJoypadMotion:
		return

	# 忽略非当前手柄的设备（防止误触和摇杆漂移）
	if input_event.device != joy_index:
		return

	if input_event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		var motion := input_event as InputEventJoypadMotion
		if abs(motion.axis_value) > DEADZONE:
			var idx := motion.axis
			var map := JoyMapping.new(JoyMapping.Type.AXIS, idx)
			map.inverted = joy_mapping_axis_invert.button_pressed
			if joy_mapping_full_axis.button_pressed:
				map.axis = JoyMapping.Axis.FULL
			elif motion.axis_value > 0:
				map.axis = JoyMapping.Axis.HALF_PLUS
			else:
				map.axis = JoyMapping.Axis.HALF_MINUS
			joy_mapping_text.text = map.to_human_string()
			cur_mapping[steps[cur_step]] = map
	elif input_event is InputEventJoypadButton and input_event.pressed:
		get_viewport().set_input_as_handled()
		var btn := input_event as InputEventJoypadButton
		var map := JoyMapping.new(JoyMapping.Type.BTN, btn.button_index)
		joy_mapping_text.text = map.to_human_string()
		cur_mapping[steps[cur_step]] = map


## 从映射字典生成 SDL2 格式的映射字符串。
func create_mapping_string(mapping: Dictionary) -> String:
	var string: String = "%s,%s," % [joy_guid, joy_name]

	for k: String in mapping:
		var m: Variant = mapping[k]
		if typeof(m) == TYPE_OBJECT and m.type == JoyMapping.Type.NONE:
			continue
		string += "%s:%s," % [k, str(m)]

	var platform: String = "Unknown"
	if JoyMapping.PLATFORMS.keys().has(OS.get_name()):
		platform = JoyMapping.PLATFORMS[OS.get_name()]

	return string + "platform:" + platform


## 开始重映射流程。
func start(idx: int) -> void:
	joy_index = idx
	joy_guid = Input.get_joy_guid(idx)
	joy_name = Input.get_joy_name(idx)
	if joy_guid.is_empty():
		push_error("Unable to find controller")
		return
	if OS.has_feature("web"):
		# Web 上建议尝试已知映射
		$Start.window_title = "%s - %s" % [joy_guid, joy_name]
		$Start.popup_centered()
	else:
		# 直接运行向导
		_on_Wizard_pressed()


## 完成映射并关闭向导。
func remap_and_close(mapping: Dictionary) -> void:
	last_mapping = create_mapping_string(mapping)
	Input.add_joy_mapping(last_mapping, true)
	reset()
	show_map()


## 重置向导状态。
func reset() -> void:
	$Start.hide()
	$Mapping.hide()
	joy_guid = ""
	joy_name = ""
	cur_mapping = {}
	cur_step = -1


## 进入下一步映射。
func step_next() -> void:
	$Mapping.title = "Step: %d/%d" % [cur_step + 1, steps.size()]
	joy_mapping_text.text = ""
	if cur_step >= steps.size():
		remap_and_close(cur_mapping)
	else:
		_update_step()


## 显示最终映射字符串。
func show_map() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.prompt('This is the resulting remap string', '%s')" % last_mapping)
	else:
		$MapWindow/Margin/VBoxContainer/TextEdit.text = last_mapping
		$MapWindow.popup_centered()


## 更新当前步骤的 UI 显示。
func _update_step() -> void:
	$Mapping/Margin/VBox/Info/Buttons/Next.grab_focus()
	for btn in joy_buttons.get_children():
		btn.hide()
	for axis in joy_axes.get_children():
		axis.hide()
	var key: String = steps[cur_step]
	var idx: int = JoyMapping.BASE[key]
	if key in ["leftx", "lefty", "rightx", "righty"]:
		joy_axes.get_node(str(idx) + "+").show()
		joy_axes.get_node(str(idx) + "-").show()
	elif key in ["lefttrigger", "righttrigger"]:
		joy_axes.get_node(str(idx)).show()
	else:
		joy_buttons.get_node(str(idx)).show()

	joy_mapping_full_axis.button_pressed = key in ["leftx", "lefty", "rightx", "righty", "righttrigger", "lefttrigger"]
	joy_mapping_axis_invert.button_pressed = false
	if cur_mapping.has(key):
		var cur: JoyMapping = cur_mapping[steps[cur_step]]
		joy_mapping_text.text = cur.to_human_string()
		if cur.type == JoyMapping.Type.AXIS:
			joy_mapping_full_axis.button_pressed = cur.axis == JoyMapping.Axis.FULL
			joy_mapping_axis_invert.button_pressed = cur.inverted


## 开始向导按钮回调。
func _on_Wizard_pressed() -> void:
	Input.remove_joy_mapping(joy_guid)
	$Start.hide()
	$Mapping.popup_centered()
	cur_step = 0
	step_next()


## 取消按钮回调。
func _on_Cancel_pressed() -> void:
	reset()


## 使用 Xbox 预设映射。
func _on_xbox_pressed() -> void:
	remap_and_close(JoyMapping.XBOX)


## 使用 macOS Xbox 预设映射。
func _on_xboxosx_pressed() -> void:
	remap_and_close(JoyMapping.XBOX_OSX)


## 映射窗口关闭回调。
func _on_Mapping_popup_hide() -> void:
	reset()


## 下一步按钮回调。
func _on_Next_pressed() -> void:
	cur_step += 1
	step_next()


## 上一步按钮回调。
func _on_Prev_pressed() -> void:
	if cur_step > 0:
		cur_step -= 1
		step_next()


## 跳过当前按键映射。
func _on_Skip_pressed() -> void:
	var key: String = steps[cur_step]
	if cur_mapping.has(key):
		cur_mapping.erase(key)

	cur_step += 1
	step_next()


## 全轴切换回调。
func _on_FullAxis_toggled(button_pressed: bool) -> void:
	if cur_step == -1 or not button_pressed:
		return

	var key: String = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.Type.AXIS:
		cur_mapping[key].axis = JoyMapping.Axis.FULL
		joy_mapping_text.text = cur_mapping[key].to_human_string()


## 轴反转切换回调。
func _on_InvertAxis_toggled(button_pressed: bool) -> void:
	if cur_step == -1:
		return

	var key: String = steps[cur_step]
	if cur_mapping.has(key) and cur_mapping[key].type == JoyMapping.Type.AXIS:
		cur_mapping[key].inverted = button_pressed
		joy_mapping_text.text = cur_mapping[key].to_human_string()


## 起始窗口关闭请求回调。
func _on_start_close_requested() -> void:
	$Start.hide()


## 映射窗口关闭请求回调。
func _on_mapping_close_requested() -> void:
	$Mapping.hide()


## 映射结果窗口关闭请求回调。
func _on_map_window_close_requested() -> void:
	$MapWindow.hide()
