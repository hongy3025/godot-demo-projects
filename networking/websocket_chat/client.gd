## WebSocket 聊天客户端 UI —— 聊天客户端的用户界面和事件处理。
##
## 继承自 [Control]，作为聊天客户端的 UI 界面。
## 使用 [WebSocketClient] 封装类管理网络连接。
extends Control

## WebSocket 客户端实例引用。
@onready var _client: WebSocketClient = $WebSocketClient
## 日志显示区域。
@onready var _log_dest: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
## 消息输入框。
@onready var _line_edit: LineEdit = $Panel/VBoxContainer/Send/LineEdit
## 服务器地址输入框。
@onready var _host: LineEdit = $Panel/VBoxContainer/Connect/Host


## 记录日志消息到控制台和 UI。
## 参数 msg: 日志文本。
func info(msg: String) -> void:
	print(msg)
	_log_dest.add_text(str(msg) + "\n")


#region 客户端信号处理
## 连接关闭回调。
func _on_web_socket_client_connection_closed() -> void:
	var ws := _client.get_socket()
	info("Client just disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])


## 成功连接回调。
func _on_web_socket_client_connected_to_server() -> void:
	info("Client just connected with protocol: %s" % _client.get_socket().get_selected_protocol())


## 收到消息回调。
func _on_web_socket_client_message_received(message: String) -> void:
	info("%s" % message)
#endregion

#region UI 信号处理
## "发送"按钮点击处理：发送消息到服务器。
func _on_send_pressed() -> void:
	if _line_edit.text.is_empty():
		return

	info("Sending message: %s" % [_line_edit.text])
	_client.send(_line_edit.text)
	_line_edit.text = ""


## "连接"开关切换处理：连接或断开服务器。
func _on_connect_toggled(pressed: bool) -> void:
	if not pressed:
		_client.close()
		return

	if _host.text.is_empty():
		return

	info("Connecting to host: %s." % [_host.text])
	var err := _client.connect_to_url(_host.text)
	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
#endregion
