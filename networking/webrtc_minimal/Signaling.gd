## 本地信令服务器 —— 在单机环境下为两个 WebRTC 对等端提供信令中继。
##
## 继承自 [Node]，作为本地信令服务器。
## 应添加到自动加载（Autoload）中，名称为 "Signaling" (/root/Signaling)。
## 用于在同一个进程中中继两个 WebRTC 对等端之间的 SDP 和 ICE Candidate。
extends Node

## 存储两个对等端的节点路径。
var peers: Array[String] = []


## 注册对等端到信令服务器。
## 当两个对等端都注册后，自动让第一个对等端创建 Offer。
## 参数 path: 对等端节点的路径。
func register(path: String) -> void:
	assert(peers.size() < 2)
	peers.push_back(path)
	if peers.size() == 2:
		get_node(peers[0]).peer.create_offer()


## 查找另一个已注册的对等端路径。
## 参数 path: 当前对等端路径。
## 返回: 另一个对等端的路径，未找到时返回空字符串。
func _find_other(path: String) -> String:
	for p in peers:
		if p != path:
			return p
	return ""


## 中继 SDP 会话描述到另一个对等端。
## 参数 path: 发送方路径；type: SDP 类型（offer/answer）；sdp: SDP 字符串。
func send_session(path: String, type: String, sdp: String) -> void:
	var other := _find_other(path)
	assert(not other.is_empty())
	get_node(other).peer.set_remote_description(type, sdp)


## 中继 ICE Candidate 到另一个对等端。
## 参数 path: 发送方路径；media: media 标识；index: 索引；sdp: SDP 字符串。
func send_candidate(path: String, media: String, index: int, sdp: String) -> void:
	var other := _find_other(path)
	assert(not other.is_empty())
	get_node(other).peer.add_ice_candidate(media, index, sdp)
