# Pong Multiplayer - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 ENet 和 MultiplayerAPI 实现双人联机 Pong 游戏。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**Pong Multiplayer** 是一个双人联机 Pong 游戏，使用 ENet 协议实现网络同步。与 `mono/multiplayer_pong` 功能相同，但使用 GDScript 编写。

- 语言：GDScript
- 主场景：`lobby.tscn` → `pong.tscn`
- 端口：8910

---

## 2. 快速上手

一方点击 Host，另一方输入 IP 后点击 Join。

| 按键 | 功能 |
|------|------|
| W/S 或 上/下方向键 | 移动球拍 |

---

## 3. 核心架构

```
lobby.tscn (Control)          ← 大厅管理连接
  → pong.tscn (Node2D)       ← 游戏场景
      ├── Player1 (Paddle)    ← 本地控制
      ├── Player2 (Paddle)    ← 远程控制
      └── Ball (Area2D)       ← 球
```

---

## 4. 文件逐层导读

### `lobby.gd` — 网络大厅 ⭐

`logic/lobby.gd:1` 继承 `Control`，管理 ENet 连接。

- `_on_host_pressed()` (`lobby.gd:88`) — 创建 `ENetMultiplayerPeer` 作为服务器
- `_on_join_pressed()` (`lobby.gd:109`) — 创建客户端连接
- `_player_connected()` (`lobby.gd:28`) — 有玩家连接时加载 `pong.tscn`

```gdscript
peer = ENetMultiplayerPeer.new()
peer.create_server(DEFAULT_PORT, 1)
peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
multiplayer.set_multiplayer_peer(peer)
```

### `pong.gd` — 游戏主控

`logic/pong.gd:1` 继承 `Node2D`，管理得分和权限分配。

- `_ready()` (`pong.gd:16`) — 将 Player2 的权限分配给另一个玩家
- `update_score()` (`@rpc("any_peer", "call_local")`) — 更新分数，检查获胜条件

### `paddle.gd` — 球拍控制

`logic/paddle.gd:1` 继承 `Area2D`。

- `_process()` — 本地玩家读取输入移动，通过 `set_pos_and_motion.rpc()` 同步位置
- `set_pos_and_motion()` (`@rpc("unreliable")`) — 使用不可靠传输同步位置
- `_on_paddle_area_enter()` — 球碰到球拍时调用 `area.bounce.rpc()`

### `ball.gd` — 球逻辑

`logic/ball.gd:1` 继承 `Area2D`。

- `_process()` — 每帧移动球，检测上下边界反弹
- `bounce()` (`@rpc("any_peer", "call_local")`) — 改变球的方向，加速 10%
- `_reset_ball()` (`@rpc("any_peer", "call_local")`) — 重置球到中心

---

## 5. 关键概念详解

### 5.1 权限分配

- 服务器（Host）控制 Player1 和 Ball 的权威
- 客户端（Join）控制 Player2
- `set_multiplayer_authority()` 在 `pong.gd:_ready()` 中分配

### 5.2 延迟补偿策略

球在双方各自独立移动，只有出界判定和碰撞反弹通过 RPC 同步。出界判定规则：
- 服务器判定左侧出界（自己的半场）
- 客户端判定右侧出界（自己的半场）

### 5.3 RPC 模式

- `bounce`、`stop`、`_reset_ball`：`any_peer` + `call_local`，双方都能触发
- `set_pos_and_motion`：`unreliable`，位置更新允许丢包
