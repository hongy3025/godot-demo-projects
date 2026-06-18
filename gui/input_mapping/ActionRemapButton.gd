## 动作重映射按钮 —— 用于重新绑定按键动作的自定义按钮控件。
## 继承自 [Button]，点击后进入按键监听模式，按下任意键即可重新绑定到指定动作。
extends Button


## 要重新绑定的输入动作名称，可在编辑器中设置，默认为 "ui_up"。
@export var action: String = "ui_up"


## _ready 入口：验证动作存在，初始不处理按键输入，显示当前绑定的按键。
func _ready() -> void:
	assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()


## 按钮切换回调：进入/退出按键监听模式。
## 按下时显示"请按键"提示并释放焦点；松开时恢复显示当前按键并重新获取焦点。
func _toggled(is_button_pressed: bool) -> void:
	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		text = "<press a key>"
		modulate = Color.YELLOW
		release_focus()
	else:
		display_current_key()
		modulate = Color.WHITE
		# 重新获取焦点，方便使用键盘切换到下一个按键设置。
		grab_focus()


## 处理未处理的键盘输入事件。
## 注意：也可以使用 _input() 回调，尤其是需要支持手柄时。
## 跳过 Enter 键，以便可以用键盘导航输入映射界面（代价是 Enter 键不能被绑定）。
func _unhandled_key_input(input_event: InputEvent) -> void:
	if input_event is InputEventKey and input_event.keycode != KEY_ENTER:
		remap_action_to(input_event)
		button_pressed = false


## 将动作重新绑定到指定的输入事件。
## 先修改当前游戏实例中的 InputMap，然后保存到 KeyPersistence 持久化文件。
func remap_action_to(input_event: InputEvent) -> void:
	# 先修改当前游戏实例中的事件。
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, input_event)
	# 然后保存到按键映射文件。
	KeyPersistence.keymaps[action] = input_event
	KeyPersistence.save_keymap()
	text = input_event.as_text()


## 显示当前绑定的按键文本。
func display_current_key() -> void:
	var current_key := InputMap.action_get_events(action)[0].as_text()
	text = current_key
