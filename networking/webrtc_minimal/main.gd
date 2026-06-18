## WebRTC 聊天演示主入口 —— 创建两个聊天客户端并发送测试消息。
##
## 继承自 [Node]，作为演示主场景。
## 实例化两个 [Chat] 节点，利用本地信令服务器建立 WebRTC 连接后发送消息。
extends Node

## 预加载 Chat 脚本。
const Chat = preload("res://chat.gd")


## _ready 入口：创建两个聊天客户端并发送测试消息。
func _ready() -> void:
	var p1 := Chat.new()
	var p2 := Chat.new()
	add_child(p1)
	add_child(p2)

	# 等待 1 秒后从 P1 发送消息。
	await get_tree().create_timer(1.0).timeout
	p1.send_message("Hi from %s" % String(p1.get_path()))

	# 再等待 1 秒后从 P2 发送消息。
	await get_tree().create_timer(1.0).timeout
	p2.send_message("Hi from %s" % String(p2.get_path()))
