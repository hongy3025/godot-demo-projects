# WebRTC Signaling Example - 源代码导读

> 本文档面向 Godot 新手，展示如何构建完整的 WebRTC 信令系统，包括 Godot 内置服务器和 Node.js 独立服务器。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**WebRTC Signaling Example** 是一个完整的 WebRTC 信令系统演示，包含四个部分：Godot 内置信令服务器、Godot 信令客户端、Node.js 独立信令服务器、以及使用 MultiplayerAPI 的演示 UI。

- 语言：GDScript（Godot 端）+ JavaScript（Node.js 端）
- 主场景：`demo/main.tscn`
- 默认端口：9080

---

## 2. 快速上手

1. 运行 `demo/main.tscn`
2. 点击 Listen 启动内置信令服务器
3. 在客户端面板输入服务器地址，点击 Start 连接
4. 多个客户端连接后自动建立 WebRTC 连接

---

## 3. 核心架构

```
demo/main.tscn                    ← 演示主界面
├── Server (ws_webrtc_server.gd)  ← Godot 内置信令服务器
└── Clients (多个 client_ui)      ← 客户端 UI
    └── Client (multiplayer_client.gd) ← 信令客户端
```

---

## 4. 文件逐层导读

### 4.1 信令服务器

#### `server/ws_webrtc_server.gd` — Godot 内置信令服务器 ⭐

`server/ws_webrtc_server.gd:1` 使用 `TCPServer` + `WebSocketPeer` 实现 WebSocket 信令服务器。

**核心数据结构：**
- `Peer` 类 (`ws_webrtc_server.gd:30`) — 封装 WebSocket 连接、ID、所在房间
- `Lobby` 类 (`ws_webrtc_server.gd:54`) — 封装房间（房间号、主机、成员列表）

**消息协议** (`ws_webrtc_server.gd:3-12`)：
```gdscript
enum Message {
    JOIN, PEER_CONNECT, PEER_DISCONNECT,
    OFFER, ANSWER, CANDIDATE, SEAL, ID
}
```

**关键方法：**
- `listen(port)` — 启动 TCP 服务器监听
- `poll()` — 每帧处理新连接、消息解析、超时断开
- `_join_lobby()` — 加入房间（创建新房间或加入已有房间）
- `_parse_msg()` — 解析 JSON 消息并路由到对应处理

#### `server_node/server.js` — Node.js 独立信令服务器

`server_node/server.js` 是功能相同的 Node.js 实现，使用 `ws` 库。与 Godot 版本使用相同的消息协议，可以互相替换。

### 4.2 信令客户端

#### `client/ws_webrtc_client.gd` — WebSocket 信令客户端

`client/ws_webrtc_client.gd:1` 封装了与信令服务器的 WebSocket 通信。

- `connect_to_url(url)` — 连接到信令服务器
- `join_lobby(lobby)` — 加入指定房间
- `send_offer()` / `send_answer()` / `send_candidate()` — 发送 WebRTC 信令消息
- `_parse_msg()` — 解析服务器消息并发射对应信号

**信号列表：**
| 信号 | 说明 |
|------|------|
| `lobby_joined` | 成功加入房间 |
| `connected` | 收到服务器分配的 ID |
| `peer_connected` | 新玩家加入房间 |
| `offer_received` | 收到 Offer |
| `candidate_received` | 收到 ICE 候选者 |

#### `client/multiplayer_client.gd` — MultiplayerAPI 集成

`client/multiplayer_client.gd:1` 继承 `ws_webrtc_client.gd`，将 WebRTC 连接与 Godot 的 MultiplayerAPI 集成。

- 使用 `WebRTCMultiplayerPeer` 作为 MultiplayerAPI 的传输层
- `_create_peer()` — 创建 WebRTC 连接，配置 STUN 服务器
- `_connected()` — 连接成功后创建 mesh 或 server-client 拓扑

### 4.3 演示 UI

#### `demo/main.gd` — 主控

`demo/main.gd:1` 为每个客户端分支设置独立的 MultiplayerAPI，实现多客户端同屏演示。

#### `demo/client_ui.gd` — 客户端 UI

`demo/client_ui.gd:1` 提供连接控制、Ping 测试、日志显示等功能。

---

## 5. 关键概念详解

### 5.1 信令协议

所有消息使用 JSON 格式：
```json
{"type": 0, "id": 12345, "data": "room_name"}
```

| 类型 | 值 | 方向 | 说明 |
|------|----|------|------|
| JOIN | 0 | C→S | 加入房间 |
| ID | 1 | S→C | 分配 ID |
| OFFER | 4 | C→C | WebRTC Offer |
| ANSWER | 5 | C→C | WebRTC Answer |
| CANDIDATE | 6 | C→C | ICE 候选者 |
| SEAL | 7 | C→S | 密封房间（禁止新加入） |

### 5.2 房间机制

- 创建者自动成为房间 Host（ID=1）
- 其他玩家获得自增 ID
- 支持 Mesh（P2P）和 Client-Server（通过 Host 中继）两种模式
- 房间可"密封"（Seal），禁止新玩家加入

### 5.3 STUN 服务器

使用 Google 公共 STUN 服务器（`stun:stun.l.google.com:19302`）辅助 NAT 穿透。
