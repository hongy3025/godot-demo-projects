## WebRTC 点对点聊天客户端示例 —— 使用本地信令服务器建立连接。
##
## 继承自 [Node]，作为点对点聊天客户端。
## 使用 [WebRTCPeerConnection] 建立 P2P 连接，
## 通过本地 [Signaling] 服务器中继 SDP 和 ICE Candidate。
extends Node

## WebRTC 对等端连接实例。
var peer := WebRTCPeerConnection.new()

## 创建协商好的数据通道。
var channel = peer.create_data_channel("chat", {"negotiated": true, "id": 1})


## _ready 入口：连接信号并注册到本地信令服务器。
func _ready() -> void:
	peer.ice_candidate_created.connect(_on_ice_candidate)
	peer.session_description_created.connect(_on_session)

	# 注册到本地信令服务器。
	Signaling.register(String(get_path()))


## ICE Candidate 创建回调：通过信令服务器发送给另一个对等端。
func _on_ice_candidate(media: String, index: int, sdp: String) -> void:
	Signaling.send_candidate(String(get_path()), media, index, sdp)


## SDP 创建回调：通过信令服务器发送并设置本地描述。
func _on_session(type: String, sdp: String) -> void:
	Signaling.send_session(String(get_path()), type, sdp)
	peer.set_local_description(type, sdp)


## _process 每帧处理：轮询连接并打印收到的消息。
func _process(delta: float) -> void:
	peer.poll()
	if channel.get_ready_state() == WebRTCDataChannel.STATE_OPEN:
		while channel.get_available_packet_count() > 0:
			print(String(get_path()), " received: ", channel.get_packet().get_string_from_utf8())


## 发送消息到另一个对等端。
## 参数 message: 要发送的文本消息。
func send_message(message: String) -> void:
	channel.put_packet(message.to_utf8_buffer())
