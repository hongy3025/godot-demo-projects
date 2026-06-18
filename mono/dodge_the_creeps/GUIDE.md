# Dodge the Creeps with C# - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。本项目是官方"你的第一个 2D 游戏"教程的 C# 移植版。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [场景树全景](#5-场景树全景)

---

## 1. 项目概述

**Dodge the Creeps with C#** 是一个简单的 2D 躲避游戏，玩家需要移动角色尽可能长时间地躲避敌人。这是 Godot 官方入门教程的 C# 实现。

- 语言：C#
- 主场景：`Main.tscn`
- 窗口大小：480×720

---

## 2. 快速上手

在 Godot Mono 版中打开项目，直接运行 `Main.tscn`。

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 空格 / Enter | 开始游戏 |

---

## 3. 核心架构

```
Main (Node)
├── Player (Area2D)          ← 玩家，可移动，检测碰撞
├── MobTimer (Timer)         ← 定时生成敌人
├── ScoreTimer (Timer)       ← 定时增加分数
├── StartTimer (Timer)       ← 开始倒计时
├── MobPath (Path2D)         ← 敌人生成路径
├── HUD (CanvasLayer)        ← UI 层
└── Music / DeathSound       ← 音效
```

---

## 4. 文件逐层导读

### `Main.cs` — 游戏主控 ⭐

`Main.cs:8` 定义了 `Main` 类，继承 `Node`，管理游戏生命周期。

- `NewGame()` (`Main.cs:24`) — 重置玩家位置、清空敌人、重置分数、启动开始计时器
- `GameOver()` (`Main.cs:13`) — 停止所有计时器、播放死亡音效、显示 Game Over
- `OnMobTimerTimeout()` (`Main.cs:58`) — 在 `MobPath` 上随机位置生成敌人

```csharp
Mob mob = MobScene.Instantiate<Mob>();
mobSpawnLocation.ProgressRatio = GD.Randf();
float direction = mobSpawnLocation.Rotation + Mathf.Pi / 2;
mob.Position = mobSpawnLocation.Position;
mob.LinearVelocity = velocity.Rotated(direction);
```

### `Player.cs` — 玩家控制

`Player.cs:3` 继承 `Area2D`，处理移动和碰撞。

- `_Process()` (`Player.cs:19`) — 读取 WASD 输入，计算速度向量，限制在屏幕范围内
- `Start()` (`Player.cs:74`) — 重置位置、显示玩家、启用碰撞
- `OnBodyEntered()` (`Player.cs:81`) — 碰撞到敌人时隐藏玩家、发射 `Hit` 信号

```csharp
// 8 方向移动
if (Input.IsActionPressed("move_right")) velocity.X += 1;
if (Input.IsActionPressed("move_left")) velocity.X -= 1;
// ...
velocity = velocity.Normalized() * Speed;
```

### `Mob.cs` — 敌人逻辑

`Mob.cs:3` 继承 `RigidBody2D`。

- `_Ready()` (`Mob.cs:5`) — 随机选择一个敌人动画类型
- `OnVisibleOnScreenNotifier2DScreenExited()` (`Mob.cs:12`) — 离开屏幕时自动销毁

### `HUD.cs` — UI 层

`HUD.cs:3` 继承 `CanvasLayer`，管理界面显示。

- `ShowMessage()` — 显示消息文本
- `ShowGameOver()` — 异步显示 Game Over 流程
- `OnStartButtonPressed()` — 发射 `StartGame` 信号

---

## 5. 场景树全景

```
Main (Node)
├── Player (Area2D)
│   ├── AnimatedSprite2D
│   ├── CollisionShape2D
│   └── VisibleOnScreenNotifier2D
├── MobPath (Path2D)
│   └── MobSpawnLocation (PathFollow2D)
├── MobTimer (Timer)
├── ScoreTimer (Timer)
├── StartTimer (Timer)
├── HUD (CanvasLayer)
│   ├── ScoreLabel (Label)
│   ├── MessageLabel (Label)
│   ├── MessageTimer (Timer)
│   ├── StartButton (Button)
│   └── Background (ColorRect)
├── Music (AudioStreamPlayer)
└── DeathSound (AudioStreamPlayer)
```
