## 乒乓球游戏大厅 —— 管理主机/加入、网络连接和游戏生命周期。
##
## 继承自 [Control]，作为游戏大厅 UI。
## 使用 [ENetMultiplayerPeer] 作为底层传输层，支持 ENet 压缩。
extends Control

## 默认游戏服务器端口。可以是 1024 到 49151 之间的任意数字。
## 截至 2024 年 5 月，该端口不在已注册或常用端口列表中：
## https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910

## 服务器地址输入框。
@onready var address: LineEdit = $Address
## 主机按钮。
@onready var host_button: Button = $HostButton
## 加入按钮。
@onready var join_button: Button = $JoinButton
## 成功状态标签。
@onready var status_ok: Label = $StatusOk
## 失败状态标签。
@onready var status_fail: Label = $StatusFail
## 端口转发提示标签。
@onready var port_forward_label: Label = $PortForward
## 查找公网 IP 的链接按钮。
@onready var find_public_ip_button: LinkButton = $FindPublicIP

## ENet 多人游戏对等端实例。
var peer: ENetMultiplayerPeer


## _ready 入口：连接所有网络相关的回调信号。
func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

#region SceneTree 网络回调
## 对等端连接回调：加载乒乓球场景并开始游戏。
func _player_connected(_id: int) -> void:
	var pong: Node2D = load("res://pong.tscn").instantiate()
	# 使用延迟连接以便在回调中安全删除。
	pong.game_finished.connect(_end_game, CONNECT_DEFERRED)

	get_tree().get_root().add_child(pong)
	hide()


## 对等端断开连接回调。
func _player_disconnected(_id: int) -> void:
	if multiplayer.is_server():
		_end_game("Client disconnected.")
	else:
		_end_game("Server disconnected.")


## 成功连接到服务器的回调，仅客户端执行。
func _connected_ok() -> void:
	pass


## 连接失败的回调，仅客户端执行。
func _connected_fail() -> void:
	_set_status("Couldn't connect.", false)

	multiplayer.set_multiplayer_peer(null)
	host_button.set_disabled(false)
	join_button.set_disabled(false)


## 服务器断开的回调。
func _server_disconnected() -> void:
	_end_game("Server disconnected.")
#endregion

#region 游戏创建方法
## 结束游戏：清除场景、重置对等端和 UI 状态。
## 参数 with_error: 可选的错误消息。
func _end_game(with_error: String = "") -> void:
	if has_node(^"/root/Pong"):
		get_node(^"/root/Pong").free()
		show()

	multiplayer.set_multiplayer_peer(null)
	host_button.set_disabled(false)
	join_button.set_disabled(false)

	_set_status(with_error, false)


## 设置状态显示文本。
## 参数 text: 状态文本；is_ok: 是否为成功状态。
func _set_status(text: String, is_ok: bool) -> void:
	if is_ok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)


## "主机"按钮点击处理：创建 ENet 服务器并等待玩家加入。
func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	# 设置最大 1 个对等端，因为乒乓球是双人游戏。
	var err := peer.create_server(DEFAULT_PORT, 1)
	if err != OK:
		_set_status("Can't host, address in use.",false)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for player...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server"

	port_forward_label.visible = true
	find_public_ip_button.visible = true


## "加入"按钮点击处理：连接到指定 IP 的 ENet 服务器。
func _on_join_pressed() -> void:
	var ip := address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid.", false)
		return

	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

	_set_status("Connecting...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client"
#endregion


## "查找公网 IP"链接点击处理：打开浏览器访问 icanhazip.com。
func _on_find_public_ip_pressed() -> void:
	OS.shell_open("https://icanhazip.com/")
