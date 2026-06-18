## 分支 MultiplayerAPI 演示 —— 为场景树的每个分支设置独立的 MultiplayerAPI。
##
## 继承自 [Control]，演示如何为不同的节点分支使用不同的 MultiplayerAPI 实例。
## 这在需要隔离网络通信的场景中非常有用，例如一个场景中有多个独立的多人游戏会话。
extends Control

## 存储 GridContainer 下所有子节点的路径。
var paths: Array[NodePath] = []


## _enter_tree 入口：遍历 GridContainer 的子节点，为每个子节点设置独立的 MultiplayerAPI。
func _enter_tree() -> void:
	for ch in $GridContainer.get_children():
		paths.append(NodePath(str(get_path()) + "/GridContainer/" + str(ch.name)))
	# 为每个路径分支设置专用的 MultiplayerAPI。
	for path in paths:
		get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), path)


## _exit_tree 入口：清理分支专用的 MultiplayerAPI。
func _exit_tree() -> void:
	for path in paths:
		get_tree().set_multiplayer(null, path)
