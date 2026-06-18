# WebSocket Minimal Demo - 源代码导读

> 本文档面向 Godot 新手，展示使用原生 WebSocketPeer 实现最小化的双向通信。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**WebSocket Minimal Demo** 使用 Godot 原生的 `WebSocketPeer` 和 `TCPServer` 实现最小化的 WebSocket 通信，不依赖任何封装类。

- 语言：GDScript
- 主场景：`Main.tscn`
- 端口：9080
- 窗口大小：600×300

---

## 2. 快速上手

运行 `Main.tscn`，左侧面板启动服务器，右侧面板连接。点击 Ping/Pong 按钮互发消息。

---

## 3. 核心架构

```
Main.tscn
├── ServerPanel (Control)     ← 服务器
│   └── server.gd             ← 服务器逻辑
└── ClientPanel (Control)     ← 客户端
    └── client.gd             ← 客户端逻辑
```

---

## 4. 文件逐层导读

### `server.gd` — WebSocket 服务器

`server.gd:1` 使用 `TCPServer` + `WebSocketPeer` 实现服务器。

```gdscript
var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
```

- `_ready()` (`server.gd:14`) — 启动 TCP 服务器监听端口 9080
- `_process()` (`server.gd:20`) — 每帧处理：
  1. 接受新的 TCP 连接并升级为 WebSocket
  2. 轮询 WebSocket 连接
  3. 读取收到的消息并显示

```gdscript
while tcp_server.is_connection_available():
    var conn = tcp_server.take_connection()
    socket.accept_stream(conn)

socket.poll()
if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
    while socket.get_available_packet_count():
        log_message(socket.get_packet().get_string_from_ascii())
```

- `_on_button_pong_pressed()` (`server.gd:38`) — 发送 "Pong" 消息

### `client.gd` — WebSocket 客户端

`client.gd:1` 使用 `WebSocketPeer` 连接服务器。

- `_ready()` (`client.gd:13`) — 连接到 `ws://localhost:9080`
- `_process()` (`client.gd:19`) — 每帧轮询并读取消息
- `_on_button_ping_pressed()` (`client.gd:31`) — 发送 "Ping" 消息

```gdscript
if socket.connect_to_url(websocket_url) != OK:
    log_message("Unable to connect.")
    set_process(false)
```

---

## 5. 关键概念详解

### 5.1 WebSocketPeer 工作流程

**服务器端：**
```
TCPServer.listen(port)
  → TCPServer.take_connection() 获取 TCP 连接
  → WebSocketPeer.accept_stream() 升级为 WebSocket
  → WebSocketPeer.poll() 处理握手
  → WebSocketPeer.get_packet() 读取消息
```

**客户端：**
```
WebSocketPeer.connect_to_url(url)
  → WebSocketPeer.poll() 处理连接
  → WebSocketPeer.get_ready_state() 检查连接状态
  → WebSocketPeer.send_text() 发送消息
```

### 5.2 单连接限制

此演示仅支持一个客户端连接（单个 `WebSocketPeer` 实例），适用于理解 WebSocket 基本原理。多客户端场景参考 `websocket_chat` 项目。
