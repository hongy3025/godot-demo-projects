# Multiplayer Bomber - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 ENet 和 MultiplayerAPI 实现多人炸弹人游戏。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

**Multiplayer Bomber** 是一个多人联机的炸弹人游戏，支持最多 12 名玩家。使用 ENet 协议和 Godot 的 MultiplayerSpawner 实现网络同步。

- 语言：GDScript
- 主场景：`lobby.tscn`（大厅）→ `world.tscn`（游戏）
- 端口：10567

---

## 2. 快速上手

一方输入名字后点击 Host，另一方输入 IP 后点击 Join。

| 按键 | 功能 |
|------|------|
| WASD | 移动 |
| 空格 / 鼠标左键 | 放置炸弹 |

---

## 3. 核心架构

```
gamestate.gd (Autoload)          ← 全局网络状态管理
  → lobby.tscn                   ← 大厅 UI
    → world.tscn                 ← 游戏世界
        ├── Players/             ← 玩家容器
        │   └── Player (CharacterBody2D)
        ├── BombSpawner (MultiplayerSpawner)  ← 炸弹生成器
        ├── Rocks/               ← 可破坏的岩石
        ├── Score (HBoxContainer)← 计分板
        └── TileMap              ← 地图
```

---

## 4. 文件逐层导读

### `gamestate.gd` — 全局网络状态 ⭐

`gamestate.gd:1` 作为 Autoload 全局可用，管理所有网络连接和游戏状态。

- `host_game()` / `join_game()` — 创建/加入 ENet 服务器
- `_player_connected()` / `_player_disconnected()` — 玩家连接/断开回调
- `register_player()` (`@rpc("any_peer")`) — 注册玩家名称
- `load_world()` (`@rpc("call_local")`) — 加载游戏场景
- `begin_game()` — 服务器创建所有玩家实例并分配出生点

```gdscript
# 为每个连接的玩家创建角色
for p_id in spawn_points:
    var player := player_scene.instantiate()
    player.synced_position = spawn_pos
    player.name = str(p_id)
    world.get_node("Players").add_child(player)
```

### `lobby.gd` — 大厅 UI

`lobby.gd:1` 继承 `Control`，提供连接界面和玩家列表。

- `_on_host_pressed()` — 调用 `gamestate.host_game()`
- `_on_join_pressed()` — 验证 IP 后调用 `gamestate.join_game()`
- `refresh_lobby()` — 刷新玩家列表

### `player.gd` — 玩家角色

`player.gd:1` 继承 `CharacterBody2D`。

- `_physics_process()` — 客户端预测 + 服务器权威的位置同步
- 本地玩家更新输入，服务器更新 `synced_position`，其他客户端插值
- `set_player_name()` (`@rpc("call_local")`) — 设置玩家名称和颜色
- `exploded()` (`@rpc("call_local")`) — 被炸弹炸到，进入眩晕状态

### `player_controls.gd` — 输入控制

`player_controls.gd:1` 封装玩家输入，`motion` 属性使用 setter 限制范围。

### `bomb.gd` — 炸弹逻辑

`bomb.gd:1` 继承 `Area2D`。

- `explode()` — 检测爆炸范围内的对象，使用 `PhysicsRayQueryParameters2D` 检查是否有墙壁阻挡
- `done()` — 动画结束后销毁

### `bomb_spawner.gd` — 炸弹生成器

`bomb_spawner.gd:1` 继承 `MultiplayerSpawner`，使用自定义 `spawn_function` 在所有客户端同步生成炸弹。

### `rock.gd` — 可破坏岩石

`rock.gd:1` 继承 `CharacterBody2D`，被炸到时增加放置者的分数并播放爆炸动画。

### `score.gd` — 计分板

`score.gd:1` 继承 `HBoxContainer`，实时显示所有玩家的分数，所有岩石被破坏时显示获胜者。

---

## 5. 关键概念详解

### 5.1 网络架构

- **服务器权威**：服务器控制位置同步、炸弹生成、分数更新
- **客户端预测**：客户端在本地执行物理移动，减少延迟感
- **MultiplayerSpawner**：自动在所有客户端同步生成/销毁对象

### 5.2 位置同步

```
本地玩家 → 更新输入 → 服务器验证 → 更新 synced_position → 广播给其他客户端
其他客户端 → 直接使用 synced_position → 视觉平滑
```

### 5.3 炸弹爆炸检测

炸弹爆炸时使用射线检测（`intersect_ray`），确保墙壁会阻挡爆炸伤害。
