## 炸弹人游戏状态管理 —— 处理网络连接、玩家注册、游戏生命周期。
##
## 继承自 [Node]，作为全局单例管理游戏的核心状态。
## 使用 [ENetMultiplayerPeer] 作为底层传输层。
## 负责：主机/加入游戏、玩家注册/注销、开始/结束游戏、生成玩家角色。
extends Node

## 默认游戏服务器端口。可以是 1024 到 49151 之间的任意数字。
## 截至 2024 年 5 月，该端口不在已注册或常用端口列表中：
## https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

## 最大玩家数量。
const MAX_PEERS = 12

## ENet 多人游戏对等端实例。
var peer: ENetMultiplayerPeer

## 本地玩家的名称。
var player_name: String = "The Warrior"

## 远程玩家字典，格式为 { id: name }。
var players := {}
## 已准备好的玩家 ID 列表。
var players_ready: Array[int] = []

## 玩家列表变更信号，通知大厅 UI 刷新。
signal player_list_changed()
## 连接失败信号。
signal connection_failed()
## 连接成功信号。
signal connection_succeeded()
## 游戏结束信号。
signal game_ended()
## 游戏错误信号，参数为错误码。
signal game_error(what: int)


## 对等端连接回调（SceneTree 回调）。
## 服务器向新连接的玩家发送注册请求。
func _player_connected(id: int) -> void:
	register_player.rpc_id(id, player_name)


## 对等端断开连接回调（SceneTree 回调）。
## 如果游戏正在进行中，则结束游戏；否则注销该玩家。
func _player_disconnected(id: int) -> void:
	if has_node(^"/root/World"):
		if multiplayer.is_server():
			game_error.emit("Player " + players[id] + " disconnected")
			end_game()
	else:
		unregister_player(id)


## 成功连接到服务器的回调（SceneTree 回调），仅客户端执行。
func _connected_ok() -> void:
	connection_succeeded.emit()


## 服务器断开的回调（SceneTree 回调），仅客户端执行。
func _server_disconnected() -> void:
	game_error.emit("Server disconnected")
	end_game()


## 连接失败的回调（SceneTree 回调），仅客户端执行。
func _connected_fail() -> void:
	multiplayer.set_multiplayer_peer(null)
	connection_failed.emit()


## 注册玩家。任何对等端可调用，服务器处理。
## 参数 new_player_name: 新玩家的名称。
@rpc("any_peer")
func register_player(new_player_name: String) -> void:
	var id := multiplayer.get_remote_sender_id()
	players[id] = new_player_name
	player_list_changed.emit()


## 注销玩家。
## 参数 id: 要注销的玩家 ID。
func unregister_player(id: int) -> void:
	players.erase(id)
	player_list_changed.emit()


## 加载游戏世界。在所有对等端本地调用。
## 实例化 world.tscn 场景，设置计分板，取消暂停状态。
@rpc("call_local")
func load_world() -> void:
	var world: Node2D = load("res://world.tscn").instantiate()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node(^"Lobby").hide()

	world.get_node(^"Score").add_player(multiplayer.get_unique_id(), player_name)
	for pn: int in players:
		world.get_node(^"Score").add_player(pn, players[pn])

	get_tree().paused = false


## 创建游戏主机。
## 参数 new_player_name: 主机玩家的名称。
func host_game(new_player_name: String) -> void:
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)


## 加入游戏。
## 参数 ip: 服务器 IP 地址；new_player_name: 玩家名称。
func join_game(ip: String, new_player_name: String) -> void:
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)


## 获取玩家名称列表。
## 返回: 所有远程玩家的名称数组。
func get_player_list() -> Array:
	return players.values()


## 开始游戏。仅服务器可调用。
## 加载世界场景并为每个玩家生成角色。
func begin_game() -> void:
	assert(multiplayer.is_server())
	load_world.rpc()

	var world: Node2D = get_tree().get_root().get_node(^"World")
	var player_scene: PackedScene = load("res://player.tscn")

	# 创建玩家 ID 到出生点的映射字典。
	var spawn_points := {}
	spawn_points[1] = 0
	var spawn_point_idx := 1
	for p: int in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1

	for p_id: int in spawn_points:
		var spawn_pos: Vector2 = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player := player_scene.instantiate()
		player.synced_position = spawn_pos
		player.name = str(p_id)
		world.get_node(^"Players").add_child(player)
		# RPC 必须在玩家节点添加到场景树后调用。
		player.set_player_name.rpc(player_name if p_id == multiplayer.get_unique_id() else players[p_id])


## 结束游戏：清除世界场景，发射游戏结束信号。
func end_game() -> void:
	if has_node(^"/root/World"):
		get_node(^"/root/World").queue_free()

	game_ended.emit()
	players.clear()


## _ready 入口：连接 MultiplayerAPI 的网络事件信号。
func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)


## 根据玩家名称的哈希值返回一个独特的颜色。
## 参数 p_name: 玩家名称。
## 返回: [Color] 基于名称哈希生成的 HSV 颜色。
func get_player_color(p_name: String) -> Color:
	return Color.from_hsv(wrapf(p_name.hash() * 0.001, 0.0, 1.0), 0.6, 1.0)
