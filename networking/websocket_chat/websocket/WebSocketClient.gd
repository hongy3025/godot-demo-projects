## WebSocket 聊天客户端封装 —— 高层 WebSocket 客户端 API。
##
## 继承自 [Node]，封装了 [WebSocketPeer] 的底层细节，
## 提供简洁的 connect_to_url/send/poll 接口和信号回调。
## 支持 TLS 加密、协议协商和自动重连状态管理。
class_name WebSocketClient
extends Node

## 握手时发送的自定义 HTTP 头。
@export var handshake_headers: PackedStringArray
## 支持的 WebSocket 子协议列表。
@export var supported_protocols: PackedStringArray
## TLS 选项，用于加密连接。
var tls_options: TLSOptions = null

## WebSocket 对等端实例。
var socket := WebSocketPeer.new()
## 上一次记录的 WebSocket 状态，用于检测状态变化。
var last_state := WebSocketPeer.STATE_CLOSED

## 成功连接到服务器信号。
signal connected_to_server()
## 连接关闭信号。
signal connection_closed()
## 收到消息信号，参数为消息内容。
signal message_received(message: Variant)


## 连接到指定的 WebSocket URL。
## 参数 url: WebSocket 服务器 URL（如 ws://example.com:8080）。
## 返回: [OK] 或错误码。
func connect_to_url(url: String) -> int:
	socket.supported_protocols = supported_protocols
	socket.handshake_headers = handshake_headers

	var err := socket.connect_to_url(url, tls_options)
	if err != OK:
		return err

	last_state = socket.get_ready_state()
	return OK


## 发送消息到服务器。
## 参数 message: 要发送的消息（字符串或字节数组）。
## 返回: 操作结果。
func send(message: String) -> int:
	if typeof(message) == TYPE_STRING:
		return socket.send_text(message)
	return socket.send(var_to_bytes(message))


## 获取一条待处理消息。
## 返回: 消息内容（字符串或 Variant），无消息时返回 null。
func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt := socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)


## 关闭 WebSocket 连接。
## 参数 code: 关闭状态码（默认 1000 表示正常关闭）。
## 参数 reason: 关闭原因。
func close(code: int = 1000, reason: String = "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()


## 重置 WebSocket 对等端到初始状态。
func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


## 获取底层 WebSocketPeer 实例。
## 返回: [WebSocketPeer] 实例。
func get_socket() -> WebSocketPeer:
	return socket


## 轮询 WebSocket 状态并处理消息。
##
## 检测状态变化并发射 connected_to_server / connection_closed 信号。
## 当连接打开且有消息时，发射 message_received 信号。
func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()

	var state := socket.get_ready_state()

	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			connection_closed.emit()
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		message_received.emit(get_message())


## _process 入口：每帧调用 poll。
func _process(_delta: float) -> void:
	poll()
