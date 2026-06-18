## WebRTC 原生插件下载链接按钮。
extends LinkButton


## 链接按钮点击处理：打开 WebRTC 原生插件下载页面。
func _on_LinkButton_pressed() -> void:
	OS.shell_open("https://github.com/godotengine/webrtc-native/releases")
