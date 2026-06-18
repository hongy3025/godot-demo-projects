## WebSocket 多人游戏主界面 —— 负责连接/断开网络、管理大厅 UI 状态。
##
## 继承自 [Control]，作为游戏的主菜单界面。
## 使用 [WebSocketMultiplayerPeer] 作为底层传输层，通过 Godot 的 [MultiplayerAPI] 进行 RPC 通信。
extends Control

## 默认 WebSocket 服务器端口。
const DEF_PORT = 8080

## WebSocket 子协议名称，用于握手阶段协议协商。
const PROTO_NAME = "ludus"

## 引用"主机"按钮。
@onready var _host_btn: Button = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Host
## 引用"连接"按钮。
@onready var _connect_btn: Button = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Connect
## 引用"断开"按钮。
@onready var _disconnect_btn: Button = $Panel/VBoxContainer/HBoxContainer2/HBoxContainer/Disconnect
## 玩家名称输入框。
@onready var _name_edit: LineEdit = $Panel/VBoxContainer/HBoxContainer/NameEdit
## 服务器地址输入框。
@onready var _host_edit: LineEdit = $Panel/VBoxContainer/HBoxContainer2/Hostname
## 游戏主逻辑节点引用。
@onready var _game: Control = $Panel/VBoxContainer/Game

## WebSocket 多人游戏网络对等端实例。
var peer := WebSocketMultiplayerPeer.new()


## 构造函数：设置 WebSocket 支持的子协议列表。
func _init() -> void:
	peer.supported_protocols = ["ludus"]


## _ready 入口：连接 MultiplayerAPI 的各种网络事件信号。
##
## 包括：对等端连接/断开、服务器断开、连接失败、成功连接到服务器。
## 同时根据系统用户名设置默认玩家名称。
func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_close_network)
	multiplayer.connection_failed.connect(_close_network)
	multiplayer.connected_to_server.connect(_connected)

	$AcceptDialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$AcceptDialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# 根据系统环境变量 USERNAME 设置玩家名称，如果获取不到则使用桌面路径中的用户名作为后备。
	if OS.has_environment("USERNAME"):
		_name_edit.text = OS.get_environment("USERNAME")
	else:
		var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		_name_edit.text = desktop_path[desktop_path.size() - 2]


## 开始游戏：禁用连接相关 UI 控件，显示断开按钮，启动游戏逻辑。
func start_game() -> void:
	_host_btn.disabled = true
	_name_edit.editable = false
	_host_edit.editable = false
	_connect_btn.hide()
	_disconnect_btn.show()
	_game.start()


## 停止游戏：恢复连接相关 UI 控件，隐藏断开按钮，停止游戏逻辑。
func stop_game() -> void:
	_host_btn.disabled = false
	_name_edit.editable = true
	_host_edit.editable = true
	_disconnect_btn.hide()
	_connect_btn.show()
	_game.stop()


## 关闭网络连接：停止游戏、弹出提示对话框、清除 MultiplayerPeer。
func _close_network() -> void:
	stop_game()
	$AcceptDialog.popup_centered()
	$AcceptDialog.get_ok_button().grab_focus()
	multiplayer.multiplayer_peer = null
	peer.close()


## 成功连接到服务器后的回调：通过 RPC 向服务器发送玩家名称。
func _connected() -> void:
	_game.set_player_name.rpc(_name_edit.text)


## 对等端连接回调：通知游戏逻辑层有新玩家加入。
## 参数 id: 新连接的对等端 ID。
func _peer_connected(id: int) -> void:
	_game.on_peer_add(id)


## 对等端断开连接回调：打印日志并通知游戏逻辑层。
## 参数 id: 断开连接的对等端 ID。
func _peer_disconnected(id: int) -> void:
	print("Disconnected %d" % id)
	_game.on_peer_del(id)


## "主机"按钮点击处理：创建 WebSocket 服务器并加入游戏。
func _on_Host_pressed() -> void:
	multiplayer.multiplayer_peer = null
	peer.create_server(DEF_PORT)
	multiplayer.multiplayer_peer = peer
	_game.add_player(1, _name_edit.text)
	start_game()


## "断开"按钮点击处理：关闭网络连接。
func _on_Disconnect_pressed() -> void:
	_close_network()


## "连接"按钮点击处理：创建 WebSocket 客户端并连接到指定服务器。
func _on_Connect_pressed() -> void:
	multiplayer.multiplayer_peer = null
	peer.create_client("ws://" + _host_edit.text + ":" + str(DEF_PORT))
	multiplayer.multiplayer_peer = peer
	start_game()
