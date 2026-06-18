# WebSocket Chat Demo - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 WebSocket 在 Godot 中实现聊天室，包含服务器和客户端。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**WebSocket Chat Demo** 演示了如何在 Godot 中同时运行 WebSocket 服务器和客户端，实现一个简单的聊天室。Godot 可以同时作为 WebSocket 服务器和客户端。

- 语言：GDScript
- 主场景：`combo.tscn`（服务器+客户端组合）
- 自定义 WebSocket 封装：`websocket/WebSocketServer.gd` 和 `websocket/WebSocketClient.gd`

---

## 2. 快速上手

运行 `combo.tscn`，左侧面板启动服务器，右侧面板连接 `ws://localhost:PORT`。

---

## 3. 核心架构

```
combo.tscn                    ← 组合场景
├── ServerPanel (server.tscn) ← 服务器面板
│   └── WebSocketServer       ← 自定义 WebSocket 服务器
└── ClientPanel (client.tscn) ← 客户端面板
    └── WebSocketClient       ← 自定义 WebSocket 客户端
```

---

## 4. 文件逐层导读

### 4.1 自定义 WebSocket 封装

#### `websocket/WebSocketServer.gd` — 服务器封装 ⭐

`websocket/WebSocketServer.gd:1` 使用 `class_name` 注册为全局类型，封装了 WebSocket 服务器的完整生命周期。

**关键方法：**
- `listen(port)` — 启动 TCP 服务器监听
- `stop()` — 停止服务器
- `send(peer_id, message)` — 发送消息（peer_id=0 广播，负数排除指定客户端）
- `poll()` — 每帧处理连接握手和消息接收

**信号：**
- `client_connected(peer_id)` — 新客户端连接
- `client_disconnected(peer_id)` — 客户端断开
- `message_received(peer_id, message)` — 收到消息

**连接管理：**
- `PendingPeer` 内部类处理 WebSocket 握手（支持 TLS）
- `peers` 字典存储已连接的 WebSocketPeer

#### `websocket/WebSocketClient.gd` — 客户端封装

`websocket/WebSocketClient.gd:1` 封装了 WebSocket 客户端。

- `connect_to_url(url)` — 连接到服务器
- `send(message)` — 发送消息
- `close()` — 断开连接
- `poll()` — 每帧处理连接状态和消息接收

### 4.2 业务逻辑

#### `server.gd` — 服务器 UI 逻辑

`server.gd:1` 继承 `Control`，连接 `WebSocketServer` 的信号。

- `_on_web_socket_server_client_connected()` — 新客户端连接时广播通知
- `_on_web_socket_server_message_received()` — 收到消息后广播给所有客户端
- `_on_listen_toggled()` — 启动/停止服务器

```gdscript
func _on_web_socket_server_message_received(peer_id: int, message: String) -> void:
    _server.send(-peer_id, "[%d] Says: %s" % [peer_id, message])
```

#### `client.gd` — 客户端 UI 逻辑

`client.gd:1` 继承 `Control`，连接 `WebSocketClient` 的信号。

- `_on_web_socket_client_connected_to_server()` — 连接成功
- `_on_web_socket_client_message_received()` — 显示收到的消息
- `_on_connect_toggled()` — 连接/断开服务器

---

## 5. 关键概念详解

### 5.1 Godot 作为 WebSocket 服务器

Godot 的 `WebSocketPeer` 可以接受 TCP 连接并升级为 WebSocket。自定义的 `WebSocketServer` 封装了：
1. `TCPServer` 监听端口
2. 接受 TCP 连接
3. 通过 `WebSocketPeer.accept_stream()` 升级为 WebSocket
4. 管理多个客户端连接

### 5.2 消息广播

`send()` 方法支持三种模式：
- `peer_id = 0`：广播给所有客户端
- `peer_id > 0`：发送给指定客户端
- `peer_id < 0`：广播给除指定客户端外的所有人

### 5.3 支持 TLS

`WebSocketServer` 支持通过 `tls_cert` 和 `tls_key` 启用 TLS 加密，适用于生产环境。
