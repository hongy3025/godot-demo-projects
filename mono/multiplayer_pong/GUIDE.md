# Pong Multiplayer with C# - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 C# 和 ENet 实现双人联机 Pong 游戏。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**Pong Multiplayer with C#** 是一个双人联机 Pong 游戏，使用 ENet 协议和 Godot 的 MultiplayerAPI 实现网络同步。

- 语言：C#
- 主场景：`lobby.tscn`（大厅）→ `pong.tscn`（游戏）
- 端口：8910

---

## 2. 快速上手

一方点击 Host，另一方输入 IP 地址后点击 Join。

| 按键 | 功能 |
|------|------|
| W/S 或 上/下 | 左方球拍移动 |
| 方向键上/下 | 右方球拍移动 |

---

## 3. 核心架构

```
Lobby (Control)          ← 大厅，管理连接
  → Pong (Node2D)       ← 游戏主控
      ├── Player1 (Paddle)  ← 本地控制
      ├── Player2 (Paddle)  ← 远程控制
      └── Ball (Area2D)     ← 球
```

---

## 4. 文件逐层导读

### `Lobby.cs` — 网络大厅 ⭐

`logic/Lobby.cs:5` 继承 `Control`，管理 ENet 连接。

- `OnHostPressed()` (`Lobby.cs:110`) — 创建 `ENetMultiplayerPeer` 作为服务器
- `OnJoinPressed()` (`Lobby.cs:129`) — 创建 `ENetMultiplayerPeer` 作为客户端连接
- `PlayerConnected()` (`Lobby.cs:38`) — 有玩家连接时加载 `pong.tscn` 开始游戏

```csharp
_peer = new ENetMultiplayerPeer();
Error err = _peer.CreateServer(DefaultPort, MaxNumberOfPeers);
_peer.Host.Compress(ENetConnection.CompressionMode.RangeCoder);
GetTree().GetMultiplayer().MultiplayerPeer = _peer;
```

### `Pong.cs` — 游戏主控

`logic/Pong.cs:4` 继承 `Node2D`，管理得分和权限分配。

- `_Ready()` (`Pong.cs:19`) — 将 Player2 的权限分配给另一个玩家
- `UpdateScore()` (`Pong.cs:44`, `[Rpc]`) — 更新分数，检查是否达到获胜条件

```csharp
// 服务器控制 Player1，客户端控制 Player2
if (GetTree().GetMultiplayer().IsServer())
    _playerTwo.SetMultiplayerAuthority(GetTree().GetMultiplayer().GetPeers()[0]);
else
    _playerTwo.SetMultiplayerAuthority(GetTree().GetMultiplayer().GetUniqueId());
```

### `Paddle.cs` — 球拍控制

`logic/Paddle.cs:4` 继承 `Area2D`。

- `_Process()` (`Paddle.cs:19`) — 本地玩家读取输入移动，通过 RPC 同步位置
- `SetPosAndMotion()` (`Paddle.cs:49`, `[Rpc]`) — 使用 `Unreliable` 传输模式同步位置
- `OnPaddleAreaEnter()` (`Paddle.cs:62`) — 球碰到球拍时调用球的 `Bounce` RPC

### `Ball.cs` — 球逻辑

`logic/Ball.cs:4` 继承 `Area2D`。

- `_Process()` (`Ball.cs:20`) — 每帧移动球，检测上下边界反弹
- `Bounce()` (`Ball.cs:66`, `[Rpc(AnyPeer)]`) — 改变球的方向，加速 10%
- `ResetBall()` (`Ball.cs:90`, `[Rpc(AnyPeer)]`) — 重置球到中心

---

## 5. 关键概念详解

### 5.1 多人权限模型

- 服务器（Host）控制 Player1 和 Ball
- 客户端（Join）控制 Player2
- 球出界判定：服务器判左侧出界，客户端判右侧出界，减少延迟影响

### 5.2 RPC 传输模式

- `Bounce`、`Stop`、`ResetBall` 使用 `AnyPeer` + `CallLocal`，双方都能调用
- `SetPosAndMotion` 使用 `Unreliable`，位置更新可丢包以换取速度

### 5.3 延迟补偿

球在双方各自独立移动（不依赖网络同步位置），只有出界判定和碰撞反弹通过 RPC 同步，保证视觉流畅。
