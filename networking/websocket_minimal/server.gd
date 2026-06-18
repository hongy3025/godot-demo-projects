## WebSocket 最小化服务器示例 —— 演示底层 WebSocketPeer 的服务器端用法。
##
## 继承自 [Node]，使用 [TCPServer] 接受 TCP 连接，
## 然后通过 [WebSocketPeer] 升级为 WebSocket 连接。
## 这是最底层的 WebSocket API 使用方式，不依赖 Godot 的高层 MultiplayerAPI。
extends Node

## 服务器监听端口。
const PORT = 9080

## TCP 服务器实例，用于接受新连接。
var tcp_server := TCPServer.new()
## WebSocket 对等端实例，用于处理单个客户端的 WebSocket 通信。
var socket := WebSocketPeer.new()


## 记录日志消息到 UI。
## 参数 message: 日志文本。
func log_message(message: String) -> void:
	var time: String = "[color=#aaaaaa] %s |[/color] " % Time.get_time_string_from_system()
	%TextServer.text += time + message + "\n"


## _ready 入口：启动 TCP 服务器监听指定端口。
func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
		set_process(false)


## _process 每帧处理：接受新连接并处理 WebSocket 消息。
func _process(_delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)

	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())


## _exit_tree 入口：清理 WebSocket 和 TCP 连接。
func _exit_tree() -> void:
	socket.close()
	tcp_server.stop()


## "Pong"按钮点击处理：向客户端发送 "Pong" 消息。
func _on_button_pong_pressed() -> void:
	socket.send_text("Pong")
