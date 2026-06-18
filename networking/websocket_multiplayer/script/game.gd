## 回合制游戏逻辑 —— 管理玩家列表、回合轮转和行动处理。
##
## 继承自 [Control]，作为游戏主界面。
## 使用 @rpc 注解实现网络同步，服务器作为权威端验证所有玩家行动。
extends Control

## 皇冠图标资源，用于标记当前回合的玩家。
const _crown = preload("res://img/crown.png")

## 玩家列表 UI 控件引用。
@onready var _list: ItemList = $HBoxContainer/VBoxContainer/ItemList
## 行动按钮引用。
@onready var _action: Button = $HBoxContainer/VBoxContainer/Action

## 允许的玩家行动列表。
const ACTIONS = ["roll", "pass"]

## 当前所有玩家的 ID 列表。
var _players: Array[int] = []
## 当前回合的玩家索引（在 _players 数组中的位置）。
var _turn := -1


## 向聊天日志添加消息。仅服务器可调用。
## 参数 message: 要记录的消息文本。
@rpc
func _log(message: String) -> void:
	$HBoxContainer/RichTextLabel.add_text(message + "\n")


## 设置玩家名称。任何对等端都可调用，但仅服务器处理。
## 参数 p_name: 玩家名称字符串。
@rpc("any_peer")
func set_player_name(p_name: String) -> void:
	if not is_multiplayer_authority():
		return
	var sender := multiplayer.get_remote_sender_id()
	update_player_name.rpc(sender, p_name)


## 更新玩家列表中指定玩家的显示名称。在所有对等端本地调用。
## 参数 player: 玩家 ID；p_name: 新名称。
@rpc("call_local")
func update_player_name(player: int, p_name: String) -> void:
	var pos := _players.find(player)
	if pos != -1:
		_list.set_item_text(pos, p_name)


## 处理玩家请求的行动。任何对等端可调用，仅服务器验证和执行。
## 验证：发送者是否为当前回合玩家、行动是否合法。
## 参数 action: 行动名称（必须在 ACTIONS 列表中）。
@rpc("any_peer")
func request_action(action: String) -> void:
	if not is_multiplayer_authority():
		return
	var sender := multiplayer.get_remote_sender_id()
	if _players[_turn] != sender:
		_log.rpc("Someone is trying to cheat! %s" % str(sender))
		return
	if action not in ACTIONS:
		_log.rpc("Invalid action: %s" % action)
		return

	do_action(action)
	next_turn()


## 执行行动：生成随机数值并记录日志。
## 参数 action: 执行的行动名称。
func do_action(action: String) -> void:
	var player_name := _list.get_item_text(_turn)
	var val := randi() % 100
	_log.rpc("%s: %ss %d" % [player_name, action, val])


## 设置当前回合。在所有对等端本地调用。
## 更新皇冠图标位置和行动按钮的可用状态。
## 参数 turn: 当前回合的玩家索引。
@rpc("call_local")
func set_turn(turn: int) -> void:
	_turn = turn
	if turn >= _players.size():
		return

	for i in _players.size():
		if i == turn:
			_list.set_item_icon(i, _crown)
		else:
			_list.set_item_icon(i, null)

	_action.disabled = _players[turn] != multiplayer.get_unique_id()


## 删除玩家。在所有对等端本地调用。
## 如果删除的玩家在当前回合之前，回合索引减一。
## 参数 id: 要删除的玩家 ID。
@rpc("call_local")
func del_player(id: int) -> void:
	var pos := _players.find(id)

	if pos == -1:
		return

	_players.remove_at(pos)
	_list.remove_item(pos)

	if _turn > pos:
		_turn -= 1

	if multiplayer.is_server():
		set_turn.rpc(_turn)


## 添加玩家。在所有对等端本地调用。
## 参数 id: 玩家 ID；p_name: 玩家名称（可选，为空时显示"连接中"）。
@rpc("call_local")
func add_player(id: int, p_name: String = "") -> void:
	_players.append(id)
	if p_name == "":
		_list.add_item("... connecting ...", null, false)
	else:
		_list.add_item(p_name, null, false)


## 获取指定位置玩家的名称。
## 参数 pos: 玩家在列表中的索引位置。
## 返回: 玩家名称字符串，索引越界时返回 "Error!"。
func get_player_name(pos: int) -> String:
	if pos < _list.get_item_count():
		return _list.get_item_text(pos)
	else:
		return "Error!"


## 进入下一回合：回合索引递增，循环到列表开头。
func next_turn() -> void:
	_turn += 1
	if _turn >= _players.size():
		_turn = 0
	set_turn.rpc(_turn)


## 开始游戏：将回合设为 0。
func start() -> void:
	set_turn(0)


## 停止游戏：清空玩家列表和回合状态。
func stop() -> void:
	_players.clear()
	_list.clear()
	_turn = 0
	_action.disabled = true


## 对等端加入时的处理。仅服务器执行。
## 向新加入的玩家同步已有玩家列表和当前回合状态。
## 参数 id: 新加入的玩家 ID。
func on_peer_add(id: int) -> void:
	if not multiplayer.is_server():
		return

	for i in _players.size():
		add_player.rpc_id(id, _players[i], get_player_name(i))

	add_player.rpc(id)
	set_turn.rpc_id(id, _turn)


## 对等端断开时的处理。仅服务器执行。
## 参数 id: 断开的玩家 ID。
func on_peer_del(id: int) -> void:
	if not multiplayer.is_server():
		return

	del_player.rpc(id)


## "行动"按钮点击处理。
## 服务器端：直接执行行动并进入下一回合。
## 客户端：通过 RPC 向服务器请求行动。
func _on_Action_pressed() -> void:
	if multiplayer.is_server():
		if _turn != 0:
			return
		do_action("roll")
		next_turn()
	else:
		request_action.rpc_id(1, "roll")
