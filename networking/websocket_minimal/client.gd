## WebSocket 最小化客户端示例 —— 演示底层 WebSocketPeer 的客户端用法。
##
## 继承自 [Node]，使用 [WebSocketPeer] 直接连接到 WebSocket 服务器。
## 这是最底层的 WebSocket API 使用方式，不依赖 Godot 的高层 MultiplayerAPI。
extends Node

## 要连接的 WebSocket 服务器 URL。
var websocket_url: String = "ws://localhost:9080"

## WebSocket 对等端实例。
var socket := WebSocketPeer.new()


## 记录日志消息到 UI。
## 参数 message: 日志文本。
func log_message(message: String) -> void:
	var time: String = "[color=#aaaaaa] %s |[/color] " % Time.get_time_string_from_system()
	%TextClient.text += time + message + "\n"


## _ready 入口：连接到 WebSocket 服务器。
func _ready() -> void:
	if socket.connect_to_url(websocket_url) != OK:
		log_message("Unable to connect.")
		set_process(false)


## _process 每帧处理：轮询 WebSocket 并接收消息。
func _process(_delta: float) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())


## _exit_tree 入口：关闭 WebSocket 连接。
func _exit_tree() -> void:
	socket.close()


## "Ping"按钮点击处理：向服务器发送 "Ping" 消息。
func _on_button_ping_pressed() -> void:
	socket.send_text("Ping")
