# WebRTC Minimal Connection - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 WebRTC 在 Godot 中建立点对点连接。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**WebRTC Minimal Connection** 演示了在 Godot 中使用 WebRTC 建立两个对等端之间的直接连接。包含两个场景：`minimal.tscn`（纯代码演示）和 `main.tscn`（使用信令服务器的演示）。

- 语言：GDScript
- 依赖：需要安装 webrtc-native GDExtension

---

## 2. 快速上手

运行 `minimal.tscn` 可直接看到两个对等端自动连接并互发消息。运行 `main.tscn` 需要先配置信令服务器。

---

## 3. 核心架构

```
minimal.tscn              ← 纯代码演示，无 UI
main.tscn                 ← 带 UI 的演示
  ├── Chat (Node)         ← WebRTC 聊天客户端
  └── LinkButton          ← 下载链接
Signaling.gd (Autoload)   ← 本地信令服务器
```

---

## 4. 文件逐层导读

### `minimal.gd` — 最小化 WebRTC 演示 ⭐

`minimal.gd:1` 继承 `Node`，用最少的代码展示 WebRTC 连接流程。

```gdscript
var p1 := WebRTCPeerConnection.new()
var p2 := WebRTCPeerConnection.new()
var ch1 := p1.create_data_channel("chat", { "id": 1, "negotiated": true })
var ch2 := p2.create_data_channel("chat", { "id": 1, "negotiated": true })
```

**连接流程** (`minimal.gd:10-24`)：
1. P1 创建 Offer → 设置本地描述 → 传递给 P2 作为远程描述
2. P2 创建 Answer → 设置本地描述 → 传递给 P1 作为远程描述
3. ICE 候选者双向传递

```gdscript
p1.session_description_created.connect(p1.set_local_description)
p1.session_description_created.connect(p2.set_remote_description)
p1.ice_candidate_created.connect(p2.add_ice_candidate)
```

**数据收发** (`minimal.gd:35-41`)：
- 每帧调用 `p1.poll()` / `p2.poll()` 处理网络事件
- 通过 `ch1.put_packet()` 发送，`ch1.get_packet()` 接收

### `chat.gd` — 可复用的聊天客户端

`chat.gd:1` 封装了 WebRTC 连接逻辑，配合 `Signaling` 自动完成信令交换。

- `_ready()` — 连接 ICE 和 Session 回调，注册到信令服务器
- `send_message()` — 通过 data channel 发送文本消息
- `_process()` — 轮询并接收消息

### `Signaling.gd` — 本地信令服务器 ⭐

`Signaling.gd:2` 作为 Autoload 运行，模拟信令服务器。

- `register(path)` — 注册对等端，当两个都注册后自动让第一个创建 Offer
- `send_session()` — 将 Session 描述转发给另一个对等端
- `send_candidate()` — 将 ICE 候选者转发给另一个对等端

### `main.gd` — 带 UI 的演示

`main.gd:1` 创建两个 `Chat` 实例，延时后互发消息。

---

## 5. 关键概念详解

### 5.1 WebRTC 连接流程

```
P1.create_offer()
  → P1.set_local_description(offer)
  → P2.set_remote_description(offer)
  → P2.create_answer()
    → P2.set_local_description(answer)
    → P1.set_remote_description(answer)
  → ICE 候选者双向交换
  → 连接建立，Data Channel 可用
```

### 5.2 信令服务器的作用

WebRTC 需要信令服务器来交换 Session 描述和 ICE 候选者。本项目使用本地 Autoload 模拟，实际部署需要使用 WebSocket 或 HTTP 服务器。

### 5.3 数据通道

使用 `negotiated: true` + `id: 1` 确保两端创建相同 ID 的通道，避免竞争条件。
