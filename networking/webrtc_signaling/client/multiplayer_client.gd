## WebRTC 多人游戏客户端 —— 将信令客户端与 WebRTCMultiplayerPeer 集成。
##
## 继承自 [ws_webrtc_client.gd]，在信令客户端基础上集成 [WebRTCMultiplayerPeer]，
## 自动处理 WebRTC 连接建立、ICE 协商和多人游戏对等端管理。
extends "ws_webrtc_client.gd"

## WebRTC 多人游戏对等端实例。
var rtc_mp := WebRTCMultiplayerPeer.new()
## 房间是否已封禁。
var sealed: bool = false


## 构造函数：连接所有信令信号到对应的处理函数。
func _init() -> void:
	connected.connect(_connected)
	disconnected.connect(_disconnected)

	offer_received.connect(_offer_received)
	answer_received.connect(_answer_received)
	candidate_received.connect(_candidate_received)

	lobby_joined.connect(_lobby_joined)
	lobby_sealed.connect(_lobby_sealed)
	peer_connected.connect(_peer_connected)
	peer_disconnected.connect(_peer_disconnected)


## 开始连接信令服务器。
## 参数 url: 信令服务器 URL；_lobby: 房间名称；_mesh: 是否使用 Mesh 拓扑。
func start(url: String, _lobby: String = "", _mesh: bool = true) -> void:
	stop()
	sealed = false
	mesh = _mesh
	lobby = _lobby
	connect_to_url(url)


## 停止连接并清理资源。
func stop() -> void:
	multiplayer.multiplayer_peer = null
	rtc_mp.close()
	close()


## 创建 WebRTC 对等端连接。
## 使用 Google 公共 STUN 服务器进行 NAT 穿透。
## 参数 id: 对等端 ID。
## 返回: 创建的 WebRTCPeerConnection 实例。
func _create_peer(id: int) -> WebRTCPeerConnection:
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	# 使用公共 STUN 服务器进行中等 NAT 穿透。
	# 注意：STUN 无法穿透严格 NAT（如大多数移动网络），
	# 这种情况下需要 TURN。TURN 通常没有公共服务器可用，
	# 因为需要更多资源（所有流量都通过 TURN 服务器中继）。
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.session_description_created.connect(_offer_created.bind(id))
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(id))
	rtc_mp.add_peer(peer, id)
	if id < rtc_mp.get_unique_id():
		peer.create_offer()
	return peer


## ICE Candidate 创建回调：发送给信令服务器。
func _new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	send_candidate(id, mid_name, index_name, sdp_name)


## SDP 创建回调：设置本地描述并发送给信令服务器。
func _offer_created(type: String, data: String, id: int) -> void:
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


## 信令连接成功回调：创建 WebRTC 多人游戏对等端。
func _connected(id: int, use_mesh: bool) -> void:
	print("Connected %d, mesh: %s" % [id, use_mesh])
	if use_mesh:
		rtc_mp.create_mesh(id)
	elif id == 1:
		rtc_mp.create_server()
	else:
		rtc_mp.create_client(id)
	multiplayer.multiplayer_peer = rtc_mp


## 加入房间回调：保存房间名称。
func _lobby_joined(_lobby: String) -> void:
	lobby = _lobby


## 房间封禁回调。
func _lobby_sealed() -> void:
	sealed = true


## 断开连接回调：非正常断开时清理资源。
func _disconnected() -> void:
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		stop()


## 对等端连接回调：创建对应的 WebRTC 连接。
func _peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)
	_create_peer(id)


## 对等端断开回调：移除 WebRTC 对等端。
func _peer_disconnected(id: int) -> void:
	if rtc_mp.has_peer(id):
		rtc_mp.remove_peer(id)


## 收到 SDP Offer 回调：设置远程描述。
func _offer_received(id: int, offer: String) -> void:
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


## 收到 SDP Answer 回调：设置远程描述。
func _answer_received(id: int, answer: String) -> void:
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


## 收到 ICE Candidate 回调：添加到 WebRTC 连接。
func _candidate_received(id: int, mid: String, index: int, sdp: String) -> void:
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
