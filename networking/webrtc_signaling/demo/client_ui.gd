## WebRTC 信令演示客户端 UI —— 单个客户端的用户界面和事件处理。
##
## 继承自 [Control]，作为 WebRTC 信令演示中单个客户端的 UI。
## 连接信令客户端的所有信号，并处理 MultiplayerAPI 的网络事件。
extends Control

## 信令客户端节点引用。
@onready var client: Node = $Client
## 服务器地址输入框。
@onready var host: LineEdit = $VBoxContainer/Connect/Host
## 房间密钥输入框。
@onready var room: LineEdit = $VBoxContainer/Connect/RoomSecret
## 是否使用 Mesh 拓扑的复选框。
@onready var mesh: CheckBox = $VBoxContainer/Connect/Mesh


## _ready 入口：连接信令客户端和 MultiplayerAPI 的信号。
func _ready() -> void:
	client.lobby_joined.connect(_lobby_joined)
	client.lobby_sealed.connect(_lobby_sealed)
	client.connected.connect(_connected)
	client.disconnected.connect(_disconnected)

	multiplayer.connected_to_server.connect(_mp_server_connected)
	multiplayer.connection_failed.connect(_mp_server_disconnect)
	multiplayer.server_disconnected.connect(_mp_server_disconnect)
	multiplayer.peer_connected.connect(_mp_peer_connected)
	multiplayer.peer_disconnected.connect(_mp_peer_disconnected)


## 测试用 RPC 方法：接收来自其他对等端的 Ping。
## 参数 argument: 随机浮点数。
@rpc("any_peer", "call_local")
func ping(argument: float) -> void:
	_log("[Multiplayer] Ping from peer %d: arg: %f" % [multiplayer.get_remote_sender_id(), argument])


## MultiplayerAPI 服务器连接成功回调。
func _mp_server_connected() -> void:
	_log("[Multiplayer] Server connected (I am %d)" % client.rtc_mp.get_unique_id())


## MultiplayerAPI 服务器断开回调。
func _mp_server_disconnect() -> void:
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())


## MultiplayerAPI 对等端连接回调。
func _mp_peer_connected(id: int) -> void:
	_log("[Multiplayer] Peer %d connected" % id)


## MultiplayerAPI 对等端断开回调。
func _mp_peer_disconnected(id: int) -> void:
	_log("[Multiplayer] Peer %d disconnected" % id)


## 信令连接成功回调。
func _connected(id: int, use_mesh: bool) -> void:
	_log("[Signaling] Server connected with ID: %d. Mesh: %s" % [id, use_mesh])


## 信令断开回调。
func _disconnected() -> void:
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])


## 加入房间回调。
func _lobby_joined(lobby: String) -> void:
	_log("[Signaling] Joined lobby %s" % lobby)


## 房间封禁回调。
func _lobby_sealed() -> void:
	_log("[Signaling] Lobby has been sealed")


## 内部日志方法：同时输出到控制台和 UI。
## 参数 msg: 日志文本。
func _log(msg: String) -> void:
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"


## "查看对等端"按钮点击处理：打印当前连接的对等端列表。
func _on_peers_pressed() -> void:
	_log(str(multiplayer.get_peers()))


## "Ping"按钮点击处理：向所有对等端发送 RPC Ping。
func _on_ping_pressed() -> void:
	ping.rpc(randf())


## "封禁房间"按钮点击处理。
func _on_seal_pressed() -> void:
	client.seal_lobby()


## "开始"按钮点击处理：连接到信令服务器。
func _on_start_pressed() -> void:
	client.start(host.text, room.text, mesh.button_pressed)


## "停止"按钮点击处理：断开连接。
func _on_stop_pressed() -> void:
	client.stop()
