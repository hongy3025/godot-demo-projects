## 手柄测试演示 —— 显示手柄按键和摇杆的实时状态。
##
## 继承自 [Control]，以图形化方式展示手柄的按钮按下状态、
## 摇杆方向和力度、振动控制以及重映射功能。
extends Control

# 手柄演示，作者 Dana Olson <dana@shineuponthee.com>
#
# 这是一个手柄支持演示，同时也作为类似 jstest-gtk 的测试工具。
#
# 基于 MIT 许可证发布

## 摇杆死区阈值
const DEADZONE = 0.2
## 默认字体颜色（半透明白）
const FONT_COLOR_DEFAULT = Color(1.0, 1.0, 1.0, 0.5)
## 激活状态字体颜色（亮绿色）
const FONT_COLOR_ACTIVE = Color(0.2, 1.0, 0.2, 1.0)

## 当前手柄编号
var joy_num := 0
## 当前选中的手柄
var cur_joy := -1
## 摇杆当前值
var axis_value := 0.0

@onready var axes: VBoxContainer = $Axes
@onready var button_grid: GridContainer = $Buttons/ButtonGrid
@onready var joypad_axes: Node2D = $JoypadDiagram/Axes
@onready var joypad_buttons: Node2D = $JoypadDiagram/Buttons
@onready var joypad_name: RichTextLabel = $DeviceInfo/JoyName
@onready var joypad_number: SpinBox = $DeviceInfo/JoyNumber


## _ready 入口，连接手柄连接/断开信号并列出已连接手柄。
func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	for joypad in Input.get_connected_joypads():
		print_rich("Found joypad #%d: [b]%s[/b] - %s" % [joypad, Input.get_joy_name(joypad), Input.get_joy_guid(joypad)])


## _process 入口，每帧更新摇杆值和按钮状态。
func _process(_delta: float) -> void:
	# 从旋钮获取手柄设备编号
	joy_num = int(joypad_number.value)

	# 如果手柄编号变化，更新显示名称
	if joy_num != cur_joy:
		cur_joy = joy_num
		if Input.get_joy_name(joy_num) != "":
			set_joypad_name(Input.get_joy_name(joy_num), Input.get_joy_guid(joy_num))
		else:
			clear_joypad_name()


	# 遍历摇杆并显示当前值
	for axis in range(int(min(JOY_AXIS_MAX, 10))):
		axis_value = Input.get_joy_axis(joy_num, axis)
		axes.get_node("Axis" + str(axis) + "/ProgressBar").set_value(100 * axis_value)
		axes.get_node("Axis" + str(axis) + "/ProgressBar/Value").set_text("[center][fade start=2 length=16]%s[/fade][/center]" % axis_value)
		# 用有效范围计算 alpha 值，排除死区
		var scaled_alpha_value: float = (abs(axis_value) - DEADZONE) / (1.0 - DEADZONE)
		# 显示手柄方向指示器
		if axis <= JOY_AXIS_RIGHT_Y:
			if abs(axis_value) < DEADZONE:
				joypad_axes.get_node(str(axis) + "+").hide()
				joypad_axes.get_node(str(axis) + "-").hide()
			elif axis_value > 0:
				joypad_axes.get_node(str(axis) + "+").show()
				joypad_axes.get_node(str(axis) + "-").hide()
				# 透明白色调制，不改变非 alpha 颜色通道
				joypad_axes.get_node(str(axis) + "+").self_modulate.a = scaled_alpha_value
			else:
				joypad_axes.get_node(str(axis) + "+").hide()
				joypad_axes.get_node(str(axis) + "-").show()
				# 透明白色调制，不改变非 alpha 颜色通道
				joypad_axes.get_node(str(axis) + "-").self_modulate.a = scaled_alpha_value
		elif axis == JOY_AXIS_TRIGGER_LEFT || axis == JOY_AXIS_TRIGGER_RIGHT:
			if axis_value <= DEADZONE:
				joypad_axes.get_node(str(axis)).hide()
			else:
				joypad_axes.get_node(str(axis)).show()
				# 透明白色调制，不改变非 alpha 颜色通道
				joypad_axes.get_node(str(axis)).self_modulate.a = scaled_alpha_value

		# 高亮处于"激活"值范围的摇杆标签
		axes.get_node("Axis" + str(axis) + "/Label").add_theme_color_override(&"font_color", FONT_COLOR_DEFAULT)
		if abs(axis_value) >= DEADZONE:
			axes.get_node("Axis" + str(axis) + "/Label").add_theme_color_override(&"font_color", FONT_COLOR_ACTIVE)

	# 遍历按钮并高亮按下的按钮
	for button in range(int(min(JOY_BUTTON_SDL_MAX, 21))):
		if Input.is_joy_button_pressed(joy_num, button):
			button_grid.get_child(button).add_theme_color_override(&"font_color", FONT_COLOR_ACTIVE)
			if button <= JOY_BUTTON_MISC1:
				joypad_buttons.get_child(button).show()
		else:
			button_grid.get_child(button).add_theme_color_override(&"font_color", FONT_COLOR_DEFAULT)
			if button <= JOY_BUTTON_MISC1:
				joypad_buttons.get_child(button).hide()


## 手柄连接/断开事件回调。
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		print_rich("[color=green][b]+[/b] Found newly connected joypad #%d: [b]%s[/b] - %s[/color]" % [device_id, Input.get_joy_name(device_id), Input.get_joy_guid(device_id)])
	else:
		print_rich("[color=red][b]-[/b] Disconnected joypad #%d.[/color]" % device_id)

	if device_id == cur_joy:
		# 更新当前手柄标签
		if connected:
			set_joypad_name(Input.get_joy_name(device_id), Input.get_joy_guid(device_id))
		else:
			clear_joypad_name()


## 开始振动按钮回调。
func _on_start_vibration_pressed() -> void:
	var weak: float = $Vibration/Weak/Value.get_value()
	var strong: float = $Vibration/Strong/Value.get_value()
	var duration: float = $Vibration/Duration/Value.get_value()
	Input.start_joy_vibration(cur_joy, weak, strong, duration)


## 停止振动按钮回调。
func _on_stop_vibration_pressed() -> void:
	Input.stop_joy_vibration(cur_joy)


## 打开重映射向导。
func _on_Remap_pressed() -> void:
	$RemapWizard.start(cur_joy)


## 清除手柄映射。
func _on_Clear_pressed() -> void:
	var guid := Input.get_joy_guid(cur_joy)
	if guid.is_empty():
		push_error("No gamepad selected.")
		return

	Input.remove_joy_mapping(guid)


## 显示当前映射字符串。
func _on_Show_pressed() -> void:
	$RemapWizard.show_map()


## 手柄名称中的链接点击回调。
func _on_joy_name_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


## 设置手柄名称和 GUID 显示。
func set_joypad_name(joy_name: String, joy_guid: String) -> void:
	# 使 GUID 可点击（链接到 Godot 的游戏控制器数据库）
	joypad_name.set_text("%s\n[color=#fff9][url=https://github.com/godotengine/godot/blob/master/core/input/gamecontrollerdb.txt]%s[/url][/color]" % [joy_name, joy_guid])

	# 使其余 UI 显示为启用状态
	for node: CanvasItem in [$JoypadDiagram, $Axes, $Buttons, $Vibration, $VBoxContainer]:
		node.modulate.a = 1.0


## 清除手柄名称显示。
func clear_joypad_name() -> void:
	joypad_name.set_text("[i]No controller detected at ID %d.[/i]" % joypad_number.value)

	# 使其余 UI 显示为禁用状态
	for node: CanvasItem in [$JoypadDiagram, $Axes, $Buttons, $Vibration, $VBoxContainer]:
		node.modulate.a = 0.5
