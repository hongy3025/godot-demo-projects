## WebSocket 信令服务器 —— 为 WebRTC 提供房间管理和消息中继。
##
## 继承自 [Node]，作为 WebRTC 信令服务器。
## 使用 WebSocket 作为信令通道，管理多个房间（Lobby），
## 在房间内的对等端之间中继 SDP Offer/Answer 和 ICE Candidate 消息。
##
## 核心功能：
## - 房间创建/加入/离开/封禁
## - 对等端超时检测
## - 支持 Mesh 和 Client-Server 两种拓扑
extends Node

## 消息类型枚举，对应信令协议中的各种操作。
enum Message {
	JOIN,            ## 加入房间
	ID,              ## 分配 ID
	PEER_CONNECT,    ## 对等端连接通知
	PEER_DISCONNECT, ## 对等端断开通知
	OFFER,           ## SDP Offer
	ANSWER,          ## SDP Answer
	CANDIDATE,       ## ICE Candidate
	SEAL,            ## 封禁房间
}

## 无响应客户端超时时间（毫秒）。
const TIMEOUT = 1000

## 封禁房间的自动关闭时间（毫秒）。
const SEAL_TIME = 10000

## 所有字母数字字符，用于生成随机房间 ID。
const ALFNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

## ALFNUM 的 ASCII 字节缓冲区。
var _alfnum := ALFNUM.to_ascii_buffer()

## 随机数生成器。
var rand: RandomNumberGenerator = RandomNumberGenerator.new()
## 房间字典，格式为 { 房间名称: Lobby }。
var lobbies: Dictionary = {}
## TCP 服务器实例。
var tcp_server := TCPServer.new()
## 对等端字典，格式为 { 对等端 ID: Peer }。
var peers: Dictionary = {}


## 对等端类 —— 表示一个 WebSocket 连接的对等端。
class Peer extends RefCounted:
	var id := -1                    ## 对等端唯一 ID
	var lobby: String = ""          ## 所在房间名称
	var time := Time.get_ticks_msec()  ## 最后活动时间戳
	var ws := WebSocketPeer.new()   ## WebSocket 对等端实例


	## 构造函数：接受 TCP 流并创建 WebSocket 连接。
	func _init(peer_id: int, tcp: StreamPeer) -> void:
		id = peer_id
		ws.accept_stream(tcp)


	## 检查 WebSocket 是否处于打开状态。
	func is_ws_open() -> bool:
		return ws.get_ready_state() == WebSocketPeer.STATE_OPEN


	## 发送 JSON 格式的消息。
	## 参数 type: 消息类型；id: 目标 ID；data: 消息数据。
	func send(type: int, id: int, data: String = "") -> void:
		return ws.send_text(JSON.stringify({
			"type": type,
			"id": id,
			"data": data,
		}))


## 房间类 —— 表示一个信令房间。
class Lobby extends RefCounted:
	var peers := {}    ## 房间内的对等端字典
	var host := -1     ## 房间创建者（主机）的 ID
	var sealed: bool = false  ## 房间是否已封禁
	var time := 0      ## 封禁时间戳（毫秒）
	var mesh: bool = true  ## 是否使用 Mesh 拓扑


	## 构造函数。
	func _init(host_id: int, use_mesh: bool) -> void:
		host = host_id
		mesh = use_mesh


	## 对等端加入房间。
	## 向新对等端发送 ID，向房间内其他对等端发送 PEER_CONNECT。
	## 参数 peer: 要加入的对等端。
	## 返回: 是否成功加入。
	func join(peer: Peer) -> bool:
		if sealed: return false
		if not peer.is_ws_open(): return false
		peer.send(Message.ID, (1 if peer.id == host else peer.id), "true" if mesh else "")
		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			if not mesh and p.id != host:
				continue
			p.send(Message.PEER_CONNECT, peer.id)
			peer.send(Message.PEER_CONNECT, (1 if p.id == host else p.id))
		peers[peer.id] = peer
		return true


	## 对等端离开房间。
	## 如果离开的是主机，则断开所有对等端。
	## 参数 peer: 要离开的对等端。
	## 返回: 是否应关闭房间。
	func leave(peer: Peer) -> bool:
		if not peers.has(peer.id):
			return false

		peers.erase(peer.id)
		var close: bool = false
		if peer.id == host:
			close = true
		if sealed:
			return close

		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			if close:
				p.ws.close()
			else:
				p.send(Message.PEER_DISCONNECT, peer.id)

		return close


	## 封禁房间。仅主机可调用。
	## 向所有对等端发送 SEAL 消息并清空对等端列表。
	## 参数 peer_id: 请求封禁的对等端 ID。
	## 返回: 是否成功封禁。
	func seal(peer_id: int) -> bool:
		if host != peer_id:
			return false

		sealed = true

		for p: Peer in peers.values():
			if not p.is_ws_open():
				continue
			p.send(Message.SEAL, 0)

		time = Time.get_ticks_msec()
		peers.clear()

		return true


## _process 入口：每帧调用 poll 处理网络事件。
func _process(_delta: float) -> void:
	poll()


## 在指定端口开始监听。
## 参数 port: 监听端口号。
func listen(port: int) -> void:
	if OS.has_feature("web"):
		OS.alert("Cannot create WebSocket servers in Web exports due to browsers' limitations.")
		return
	stop()
	rand.seed = int(Time.get_unix_time_from_system())
	tcp_server.listen(port)


## 停止服务器并清理所有对等端。
func stop() -> void:
	tcp_server.stop()
	peers.clear()


## 主轮询函数：处理新连接、对等端消息、超时和房间封禁。
func poll() -> void:
	if not tcp_server.is_listening():
		return

	if tcp_server.is_connection_available():
		var id := randi() % (1 << 31)
		peers[id] = Peer.new(id, tcp_server.take_connection())

	# 轮询所有对等端。
	var to_remove := []
	for p: Peer in peers.values():
		# 超时检测：未加入房间且超时的对等端将被断开。
		if p.lobby.is_empty() and Time.get_ticks_msec() - p.time > TIMEOUT:
			p.ws.close()
		p.ws.poll()
		while p.is_ws_open() and p.ws.get_available_packet_count():
			if not _parse_msg(p):
				print("Parse message failed from peer %d" % p.id)
				to_remove.push_back(p.id)
				p.ws.close()
				break
		var state := p.ws.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED:
			print("Peer %d disconnected from lobby: '%s'" % [p.id, p.lobby])
			if lobbies.has(p.lobby) and lobbies[p.lobby].leave(p):
				print("Deleted lobby %s" % p.lobby)
				lobbies.erase(p.lobby)
			to_remove.push_back(p.id)

	# 房间封禁超时处理。
	for k: String in lobbies:
		if not lobbies[k].sealed:
			continue
		if lobbies[k].time + SEAL_TIME < Time.get_ticks_msec():
			for p: Peer in lobbies[k].peers:
				p.ws.close()
				to_remove.push_back(p.id)

	# 清理断开的对等端。
	for id: int in to_remove:
		peers.erase(id)


## 加入房间处理。
## 如果 lobby 为空则创建新房间并生成随机 ID。
## 参数 peer: 对等端；lobby: 房间名称；mesh: 是否使用 Mesh 拓扑。
## 返回: 是否成功加入。
func _join_lobby(peer: Peer, lobby: String, mesh: bool) -> bool:
	if lobby.is_empty():
		for _i in 32:
			lobby += char(_alfnum[rand.randi_range(0, ALFNUM.length() - 1)])
		lobbies[lobby] = Lobby.new(peer.id, mesh)
	elif not lobbies.has(lobby):
		return false
	lobbies[lobby].join(peer)
	peer.lobby = lobby
	peer.send(Message.JOIN, 0, lobby)
	print("Peer %d joined lobby: '%s'" % [peer.id, lobby])
	return true


## 解析对等端发来的 JSON 消息。
## 参数 peer: 发送消息的对等端。
## 返回: 是否成功解析。
func _parse_msg(peer: Peer) -> bool:
	var pkt_str: String = peer.ws.get_packet().get_string_from_utf8()
	var parsed: Dictionary = JSON.parse_string(pkt_str)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("type") or not parsed.has("id") or \
		typeof(parsed.get("data")) != TYPE_STRING:
		return false
	if parsed.type is not float or parsed.id is not float:
		return false

	var msg := {
		"type": str(parsed.type).to_int(),
		"id": str(parsed.id).to_int(),
		"data": parsed.data,
	}

	if msg.type == Message.JOIN:
		if peer.lobby:
			return false
		return _join_lobby(peer, msg.data, msg.id == 0)

	if not lobbies.has(peer.lobby):
		return false

	var lobby: Lobby = lobbies[peer.lobby]

	if msg.type == Message.SEAL:
		return lobby.seal(peer.id)

	var dest_id: int = msg.id
	if dest_id == MultiplayerPeer.TARGET_PEER_SERVER:
		dest_id = lobby.host

	if not peers.has(dest_id):
		return false

	if peers[dest_id].lobby != peer.lobby:
		return false

	if msg.type in [Message.OFFER, Message.ANSWER, Message.CANDIDATE]:
		var source := MultiplayerPeer.TARGET_PEER_SERVER if peer.id == lobby.host else peer.id
		peers[dest_id].send(msg.type, source, msg.data)
		return true

	return false
