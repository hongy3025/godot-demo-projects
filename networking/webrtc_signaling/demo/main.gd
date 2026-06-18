## WebRTC 信令演示主界面 —— 管理信令服务器和多个客户端实例。
##
## 继承自 [Control]，作为 WebRTC 信令演示的主界面。
## 为每个客户端子节点设置独立的 MultiplayerAPI，实现多客户端同屏演示。
extends Control


## _enter_tree 入口：为每个客户端子节点创建独立的 MultiplayerAPI。
func _enter_tree() -> void:
	for c in $VBoxContainer/Clients.get_children():
		get_tree().set_multiplayer(
				MultiplayerAPI.create_default_interface(),
				NodePath("%s/VBoxContainer/Clients/%s" % [get_path(), c.name])
			)


## _ready 入口：在 Web 导出时隐藏信令服务器控件。
func _ready() -> void:
	if OS.get_name() == "Web":
		$VBoxContainer/Signaling.hide()


## "监听"开关切换处理：启动或停止信令服务器。
func _on_listen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$Server.listen(int($VBoxContainer/Signaling/Port.value))
	else:
		$Server.stop()


## 链接按钮点击处理：打开 WebRTC 原生插件下载页面。
func _on_LinkButton_pressed() -> void:
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
