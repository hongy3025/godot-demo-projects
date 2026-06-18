## WebRTC 信令客户端 —— 通过 WebSocket 与信令服务器通信。
##
## 继承自 [Node]，作为 WebRTC 信令系统的客户端。
## 使用 [WebSocketPeer] 与信令服务器通信，处理房间加入/离开、
## SDP Offer/Answer 和 ICE Candidate 的中继。
extends Node

## 消息类型枚举，与信令服务器协议对应。
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

## 是否在连接后自动加入房间。
@export var autojoin: bool = true
## 要加入的房间名称。为空时由服务器创建新房间。
@export var lobby: String = ""
## 是否使用 Mesh 拓扑。false 时使用主机作为中继。
@export var mesh: bool = true

## WebSocket 对等端实例。
var ws := WebSocketPeer.new()
## 断开连接时的关闭状态码。
var code := 1000
## 断开连接的原因。
var reason: String = "Unknown"
## 上一次记录的 WebSocket 状态。
var old_state := WebSocketPeer.STATE_CLOSED

## 加入房间信号，参数为房间名称。
signal lobby_joined(lobby: String)
## 连接成功信号，参数为分配的 ID 和是否使用 Mesh。
signal connected(id: int, use_mesh: bool)
## 断开连接信号。
signal disconnected()
## 对等端连接信号。
signal peer_connected(id: int)
## 对等端断开信号。
signal peer_disconnected(id: int)
## 收到 SDP Offer 信号。
signal offer_received(id: int, offer: String)
## 收到 SDP Answer 信号。
signal answer_received(id: int, answer: String)
## 收到 ICE Candidate 信号。
signal candidate_received(id: int, mid: String, index: int, sdp: String)
## 房间封禁信号。
signal lobby_sealed()


## 连接到信令服务器 URL。
## 参数 url: 信令服务器 WebSocket URL。
func connect_to_url(url: String) -> void:
	close()
	code = 1000
	reason = "Unknown"
	ws.connect_to_url(url)


## 关闭 WebSocket 连接。
func close() -> void:
	ws.close()


## _process 每帧处理：轮询 WebSocket 并解析消息。
func _process(_delta: float) -> void:
	ws.poll()
	var state := ws.get_ready_state()
	if state != old_state and state == WebSocketPeer.STATE_OPEN and autojoin:
		join_lobby(lobby)
	while state == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count():
		if not _parse_msg():
			print("Error parsing message from server.")
	if state != old_state and state == WebSocketPeer.STATE_CLOSED:
		code = ws.get_close_code()
		reason = ws.get_close_reason()
		disconnected.emit()
	old_state = state


## 解析服务器发来的 JSON 消息并发射对应信号。
## 返回: 是否成功解析。
func _parse_msg() -> bool:
	var parsed: Dictionary = JSON.parse_string(ws.get_packet().get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("type") or not parsed.has("id") or \
		typeof(parsed.get("data")) != TYPE_STRING:
		return false

	var msg := parsed as Dictionary

	var type := int(msg.type)
	var src_id := int(msg.id)

	if type == Message.ID:
		connected.emit(src_id, msg.data == "true")
	elif type == Message.JOIN:
		lobby_joined.emit(msg.data)
	elif type == Message.SEAL:
		lobby_sealed.emit()
	elif type == Message.PEER_CONNECT:
		peer_connected.emit(src_id)
	elif type == Message.PEER_DISCONNECT:
		peer_disconnected.emit(src_id)
	elif type == Message.OFFER:
		offer_received.emit(src_id, msg.data)
	elif type == Message.ANSWER:
		answer_received.emit(src_id, msg.data)
	elif type == Message.CANDIDATE:
		var candidate: PackedStringArray = msg.data.split("\n", false)
		if candidate.size() != 3:
			return false
		if not candidate[1].is_valid_int():
			return false
		candidate_received.emit(src_id, candidate[0], candidate[1].to_int(), candidate[2])
	else:
		return false

	return true


## 加入指定房间。
## 参数 lobby: 房间名称（空字符串表示创建新房间）。
## 返回: 发送消息的结果。
func join_lobby(lobby: String) -> Error:
	return _send_msg(Message.JOIN, 0 if mesh else 1, lobby)


## 封禁当前房间。
## 返回: 发送消息的结果。
func seal_lobby() -> Error:
	return _send_msg(Message.SEAL, 0)


## 发送 ICE Candidate 到指定对等端。
## 参数 id: 目标对等端 ID；mid: media 标识；index: 索引；sdp: SDP 字符串。
## 返回: 发送消息的结果。
func send_candidate(id: int, mid: String, index: int, sdp: String) -> Error:
	return _send_msg(Message.CANDIDATE, id, "\n%s\n%d\n%s" % [mid, index, sdp])


## 发送 SDP Offer 到指定对等端。
## 参数 id: 目标对等端 ID；offer: Offer SDP 字符串。
## 返回: 发送消息的结果。
func send_offer(id: int, offer: String) -> Error:
	return _send_msg(Message.OFFER, id, offer)


## 发送 SDP Answer 到指定对等端。
## 参数 id: 目标对等端 ID；answer: Answer SDP 字符串。
## 返回: 发送消息的结果。
func send_answer(id: int, answer: String) -> Error:
	return _send_msg(Message.ANSWER, id, answer)


## 发送 JSON 格式的消息到信令服务器。
## 参数 type: 消息类型；id: 目标 ID；data: 消息数据。
## 返回: 发送结果。
func _send_msg(type: int, id: int, data: String = "") -> Error:
	return ws.send_text(JSON.stringify({
		"type": type,
		"id": id,
		"data": data,
	}))
