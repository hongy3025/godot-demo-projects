# WebSocket Multiplayer Demo - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 WebSocket 结合 Godot 的 MultiplayerAPI 实现多人游戏。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**WebSocket Multiplayer Demo** 演示了如何使用 `WebSocketMultiplayerPeer` 与 Godot 的 MultiplayerAPI 结合，实现回合制多人游戏。支持同一窗口内多个独立 MultiplayerAPI 实例。

- 语言：GDScript
- 主场景：`scene/combo.tscn`
- 端口：8080
- 协议名：`ludus`

---

## 2. 快速上手

运行 `scene/combo.tscn`，点击 Host 创建房间，其他窗口点击 Connect 加入。轮到你的回合时点击 Roll/Pass 按钮。

---

## 3. 核心架构

```
combo.tscn                    ← 多客户端组合场景
└── GridContainer
    ├── main (Control)        ← 客户端实例 1
    │   ├── Game (game.gd)    ← 游戏逻辑
    │   └── UI 控件
    └── main (Control)        ← 客户端实例 2
```

---

## 4. 文件逐层导读

### `combo.gd` — 多客户端管理 ⭐

`script/combo.gd:1` 为每个客户端分支设置独立的 MultiplayerAPI。

```gdscript
func _enter_tree() -> void:
    for ch in $GridContainer.get_children():
        paths.append(NodePath(str(get_path()) + "/GridContainer/" + str(ch.name)))
    for path in paths:
        get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), path)
```

这使得同一窗口内可以运行多个独立的网络客户端，方便开发和测试。

### `main.gd` — 客户端主控

`script/main.gd:1` 继承 `Control`，管理 WebSocket 连接和游戏生命周期。

- `_ready()` (`main.gd:20`) — 连接 MultiplayerAPI 信号，设置默认用户名
- `_on_Host_pressed()` (`main.gd:76`) — 创建 `WebSocketMultiplayerPeer` 作为服务器
- `_on_Connect_pressed()` (`main.gd:88`) — 创建客户端连接到服务器

```gdscript
peer.create_server(DEF_PORT)
multiplayer.multiplayer_peer = peer
```

- `_peer_connected()` / `_peer_disconnected()` — 转发到 `game.gd` 的 `on_peer_add/on_peer_del`
- `_connected()` — 连接成功后发送玩家名称

### `game.gd` — 游戏逻辑

`script/game.gd:1` 继承 `Control`，实现回合制游戏逻辑。

**RPC 方法：**
| 方法 | 权限 | 说明 |
|------|------|------|
| `set_player_name()` | `any_peer` | 客户端设置自己的名字 |
| `update_player_name()` | `call_local` | 更新玩家列表显示 |
| `request_action()` | `any_peer` | 客户端请求执行动作 |
| `add_player()` | `call_local` | 添加玩家到列表 |
| `del_player()` | `call_local` | 从列表移除玩家 |
| `set_turn()` | `call_local` | 设置当前回合 |
| `_log()` | 无限制 | 添加日志消息 |

**回合流程** (`game.gd:34-48`)：
1. 客户端调用 `request_action.rpc_id(1, "roll")`
2. 服务器验证发送者是否为当前回合玩家
3. 执行动作（随机数），调用 `next_turn()`
4. 广播 `set_turn.rpc()` 通知所有玩家

**防作弊** (`game.gd:38-41`)：
```gdscript
if _players[_turn] != sender:
    _log.rpc("Someone is trying to cheat! %s" % str(sender))
    return
```

---

## 5. 关键概念详解

### 5.1 WebSocketMultiplayerPeer

`WebSocketMultiplayerPeer` 是 Godot 4 新增的类，将 WebSocket 连接封装为 MultiplayerAPI 的传输层，可以直接替代 `ENetMultiplayerPeer`。

### 5.2 多 MultiplayerAPI

通过 `get_tree().set_multiplayer(api, path)` 可以为场景树的不同分支设置独立的 MultiplayerAPI，实现同一窗口内多客户端测试。

### 5.3 服务器权威

游戏逻辑在服务器端执行（`is_multiplayer_authority()` 检查），客户端只能请求动作，服务器验证后执行并广播结果。
