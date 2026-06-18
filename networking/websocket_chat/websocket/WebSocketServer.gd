## WebSocket 聊天服务器封装 —— 高层 WebSocket 服务器 API。
##
## 继承自 [Node]，封装了 [WebSocketPeer] 和 [TCPServer] 的底层细节，
## 提供简洁的 listen/send/poll 接口和信号回调。
## 支持 TLS 加密、握手超时、协议协商和多客户端管理。
class_name WebSocketServer
extends Node

## 消息接收信号，参数为对等端 ID 和消息内容。
signal message_received(peer_id: int, message: String)
## 客户端连接信号，参数为对等端 ID。
signal client_connected(peer_id: int)
## 客户端断开信号，参数为对等端 ID。
signal client_disconnected(peer_id: int)

## WebSocket 握手时发送的自定义 HTTP 头。
@export var handshake_headers := PackedStringArray()
## 支持的 WebSocket 子协议列表。
@export var supported_protocols := PackedStringArray()
## 握手超时时间（毫秒）。
@export var handshake_timout := 3000
## 是否使用 TLS 加密。
@export var use_tls: bool = false
## TLS 证书。
@export var tls_cert: X509Certificate
## TLS 密钥。
@export var tls_key: CryptoKey
## 是否拒绝新连接。设置为 true 时清空待处理队列。
@export var refuse_new_connections: bool = false:
	set(refuse):
		if refuse:
			pending_peers.clear()


## 待处理对等端类 —— 表示正在握手阶段的对等端。
class PendingPeer:
	var connect_time: int            ## 连接时间戳
	var tcp: StreamPeerTCP           ## TCP 流
	var connection: StreamPeer       ## 当前连接（TCP 或 TLS）
	var ws: WebSocketPeer            ## WebSocket 对等端

	func _init(p_tcp: StreamPeerTCP) -> void:
		tcp = p_tcp
		connection = p_tcp
		connect_time = Time.get_ticks_msec()


## TCP 服务器实例。
var tcp_server := TCPServer.new()
## 待处理对等端列表。
var pending_peers: Array[PendingPeer] = []
## 已连接的对等端字典，格式为 { 对等端 ID: WebSocketPeer }。
var peers: Dictionary


## 在指定端口开始监听。
## 参数 port: 监听端口号。
## 返回: [OK] 或错误码。
func listen(port: int) -> int:
	assert(not tcp_server.is_listening())
	return tcp_server.listen(port)


## 停止服务器并清理所有连接。
func stop() -> void:
	tcp_server.stop()
	pending_peers.clear()
	peers.clear()


## 向指定对等端发送消息。
## 参数 peer_id: 目标对等端 ID（0 广播，负数排除指定 ID）。
## 参数 message: 要发送的消息（字符串或字节数组）。
## 返回: 操作结果。
func send(peer_id: int, message: String) -> int:
	var type := typeof(message)
	if peer_id <= 0:
		for id: int in peers:
			if id == -peer_id:
				continue
			if type == TYPE_STRING:
				peers[id].send_text(message)
			else:
				peers[id].put_packet(message)
		return OK

	assert(peers.has(peer_id))
	var socket: WebSocketPeer = peers[peer_id]
	if type == TYPE_STRING:
		return socket.send_text(message)
	return socket.send(var_to_bytes(message))


## 获取指定对等端的消息。
## 参数 peer_id: 对等端 ID。
## 返回: 消息内容（字符串或 Variant），无消息时返回 null。
func get_message(peer_id: int) -> Variant:
	assert(peers.has(peer_id))
	var socket: WebSocketPeer = peers[peer_id]
	if socket.get_available_packet_count() < 1:
		return null
	var pkt: PackedByteArray = socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)


## 检查指定对等端是否有待处理消息。
## 参数 peer_id: 对等端 ID。
## 返回: 是否有消息。
func has_message(peer_id: int) -> bool:
	assert(peers.has(peer_id))
	return peers[peer_id].get_available_packet_count() > 0


## 创建 WebSocketPeer 实例并配置协议和头。
## 返回: 配置好的 WebSocketPeer 实例。
func _create_peer() -> WebSocketPeer:
	var ws := WebSocketPeer.new()
	ws.supported_protocols = supported_protocols
	ws.handshake_headers = handshake_headers
	return ws


## 主轮询函数：接受新连接、处理握手、接收消息。
func poll() -> void:
	if not tcp_server.is_listening():
		return

	while not refuse_new_connections and tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		pending_peers.append(PendingPeer.new(conn))

	var to_remove := []

	for p in pending_peers:
		if not _connect_pending(p):
			if p.connect_time + handshake_timout < Time.get_ticks_msec():
				to_remove.append(p)
			continue

		to_remove.append(p)

	for r: RefCounted in to_remove:
		pending_peers.erase(r)

	to_remove.clear()

	for id: int in peers:
		var p: WebSocketPeer = peers[id]
		p.poll()

		if p.get_ready_state() != WebSocketPeer.STATE_OPEN:
			client_disconnected.emit(id)
			to_remove.append(id)
			continue

		while p.get_available_packet_count():
			message_received.emit(id, get_message(id))

	for r: int in to_remove:
		peers.erase(r)
	to_remove.clear()


## 处理待处理对等端的 WebSocket 握手。
## 参数 p: 待处理对等端。
## 返回: true 表示握手完成（成功或失败），false 表示仍在进行中。
func _connect_pending(p: PendingPeer) -> bool:
	if p.ws != null:
		p.ws.poll()
		var state := p.ws.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			var id := randi_range(2, 1 << 30)
			peers[id] = p.ws
			client_connected.emit(id)
			return true
		elif state != WebSocketPeer.STATE_CONNECTING:
			return true
		return false
	elif p.tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return true
	elif not use_tls:
		p.ws = _create_peer()
		p.ws.accept_stream(p.tcp)
		return false

	else:
		if p.connection == p.tcp:
			assert(tls_key != null and tls_cert != null)
			var tls := StreamPeerTLS.new()
			tls.accept_stream(p.tcp, TLSOptions.server(tls_key, tls_cert))
			p.connection = tls
		p.connection.poll()
		var status: StreamPeerTLS.Status = p.connection.get_status()
		if status == StreamPeerTLS.STATUS_CONNECTED:
			p.ws = _create_peer()
			p.ws.accept_stream(p.connection)
			return false
		if status != StreamPeerTLS.STATUS_HANDSHAKING:
			return true

		return false


## _process 入口：每帧调用 poll。
func _process(_delta: float) -> void:
	poll()
