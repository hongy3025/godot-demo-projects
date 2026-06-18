## WebRTC 最小化示例 —— 在单进程中演示两个 WebRTC 对等端直接通信。
##
## 继承自 [Node]，作为主场景。
## 创建两个 [WebRTCPeerConnection] 实例（p1 和 p2），
## 通过直接连接信号实现本地通信，无需外部信令服务器。
## 演示了 WebRTC 的最基本用法：创建连接、交换 SDP/ICE、发送数据。
extends Node

## 创建两个 WebRTC 对等端连接。
var p1 := WebRTCPeerConnection.new()
var p2 := WebRTCPeerConnection.new()
## 创建协商好的数据通道（双方使用相同的 ID 和 negotiated=true）。
var ch1 := p1.create_data_channel("chat", { "id": 1, "negotiated": true })
var ch2 := p2.create_data_channel("chat", { "id": 1, "negotiated": true })


## _ready 入口：连接信号并触发 Offer 创建，然后发送测试消息。
func _ready() -> void:
	print(p1.create_data_channel("chat", { "id": 1, "negotiated": true }))
	# P1 的 SDP 创建后设置本地描述。
	p1.session_description_created.connect(p1.set_local_description)
	# P1 的 SDP 和 ICE 直接传递给 P2 设置远程描述和添加 Candidate。
	p1.session_description_created.connect(p2.set_remote_description)
	p1.ice_candidate_created.connect(p2.add_ice_candidate)

	# P2 同理。
	p2.session_description_created.connect(p2.set_local_description)
	p2.session_description_created.connect(p1.set_remote_description)
	p2.ice_candidate_created.connect(p1.add_ice_candidate)

	# 让 P1 创建 Offer 开始连接。
	p1.create_offer()

	# 等待 1 秒后从 P1 发送消息。
	await get_tree().create_timer(1).timeout
	ch1.put_packet("Hi from P1".to_utf8_buffer())

	# 再等待 1 秒后从 P2 发送消息。
	await get_tree().create_timer(1).timeout
	ch2.put_packet("Hi from P2".to_utf8_buffer())


## _process 每帧处理：轮询两个对等端并打印收到的消息。
func _process(delta: float) -> void:
	p1.poll()
	p2.poll()
	if ch1.get_ready_state() == ch1.STATE_OPEN and ch1.get_available_packet_count() > 0:
		print("P1 received: ", ch1.get_packet().get_string_from_utf8())
	if ch2.get_ready_state() == ch2.STATE_OPEN and ch2.get_available_packet_count() > 0:
		print("P2 received: ", ch2.get_packet().get_string_from_utf8())
