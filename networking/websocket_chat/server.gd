## WebSocket 聊天服务器 UI —— 聊天服务器的用户界面和事件处理。
##
## 继承自 [Control]，作为聊天服务器的 UI 界面。
## 使用 [WebSocketServer] 封装类管理网络连接。
extends Control

## WebSocket 服务器实例引用。
@onready var _server: WebSocketServer = $WebSocketServer
## 日志显示区域。
@onready var _log_dest: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
## 消息输入框。
@onready var _line_edit: LineEdit = $Panel/VBoxContainer/Send/LineEdit
## 端口选择器。
@onready var _listen_port: SpinBox = $Panel/VBoxContainer/Connect/Port


## 记录日志消息到控制台和 UI。
## 参数 msg: 日志文本。
func info(msg: String) -> void:
	print(msg)
	_log_dest.add_text(str(msg) + "\n")


#region 服务器信号处理
## 客户端连接回调。
func _on_web_socket_server_client_connected(peer_id: int) -> void:
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client connected: %d. Protocol: %s" % [peer_id, peer.get_selected_protocol()])
	_server.send(-peer_id, "[%d] connected" % peer_id)


## 客户端断开回调。
func _on_web_socket_server_client_disconnected(peer_id: int) -> void:
	var peer: WebSocketPeer = _server.peers[peer_id]
	info("Remote client disconnected: %d. Code: %d, Reason: %s" % [peer_id, peer.get_close_code(), peer.get_close_reason()])
	_server.send(-peer_id, "[%d] disconnected" % peer_id)


## 收到消息回调：记录日志并广播给所有客户端。
func _on_web_socket_server_message_received(peer_id: int, message: String) -> void:
	info("Server received data from peer %d: %s" % [peer_id, message])
	_server.send(-peer_id, "[%d] Says: %s" % [peer_id, message])
#endregion

#region UI 信号处理
## "发送"按钮点击处理：发送消息到所有客户端。
func _on_send_pressed() -> void:
	if _line_edit.text == "":
		return

	info("Sending message: %s" % [_line_edit.text])
	_server.send(0, "Server says: %s" % _line_edit.text)
	_line_edit.text = ""


## "监听"开关切换处理：启动或停止服务器。
func _on_listen_toggled(pressed: bool) -> void:
	if not pressed:
		_server.stop()
		info("Server stopped")
		return

	var port := int(_listen_port.value)
	var err := _server.listen(port)

	if err != OK:
		info("Error listing on port %s" % port)
		return
	info("Listing on port %s, supported protocols: %s" % [port, _server.supported_protocols])
#endregion
