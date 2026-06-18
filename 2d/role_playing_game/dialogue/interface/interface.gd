## 对话界面控制器 —— 显示对话文本并处理用户交互。
## 继承自 Control，管理对话的显示、翻页和信号连接。
extends Control

## 当前正在播放的对话节点引用。
var dialogue_node: Node = null

func _ready() -> void:
	visible = false


## 显示对话界面，连接对话节点的信号。
## 参数 player: 参与对话的玩家棋子。
## 参数 dialogue: 对话播放器节点。
func show_dialogue(player: Pawn, dialogue: Node) -> void:
	visible = true
	$Button.grab_focus()
	dialogue_node = dialogue

	# 检查是否已连接过信号，避免重复连接
	for c in dialogue.get_signal_connection_list(&"dialogue_started"):
		if player == c.callable.get_object():
			dialogue_node.start_dialogue()
			$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
			$Text.text = dialogue_node.dialogue_text
			return

	# 首次连接信号
	dialogue_node.dialogue_started.connect(player.set_active.bind(false))
	dialogue_node.dialogue_finished.connect(player.set_active.bind(true))
	dialogue_node.dialogue_finished.connect(hide)
	dialogue_node.dialogue_finished.connect(_on_dialogue_finished.bind(player))
	dialogue_node.start_dialogue()
	$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	$Text.text = dialogue_node.dialogue_text


## 点击按钮时切换到下一句对话。
func _on_Button_button_up() -> void:
	dialogue_node.next_dialogue()
	$Name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	$Text.text = dialogue_node.dialogue_text


## 对话结束后的清理：断开所有信号连接。
## 参数 player: 参与对话的玩家棋子。
func _on_dialogue_finished(player: Pawn) -> void:
	dialogue_node.dialogue_started.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(hide)
	dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
