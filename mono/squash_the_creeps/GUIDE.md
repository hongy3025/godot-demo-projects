# Squash the Creeps (3D) with C# - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。本项目是官方"你的第一个 3D 游戏"教程的 C# 移植版。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [场景树全景](#5-场景树全景)

---

## 1. 项目概述

**Squash the Creeps (3D) with C#** 是一个 3D 平台动作游戏，玩家需要追逐并踩扁怪物。使用 `CharacterBody3D` 实现物理移动。

- 语言：C#
- 主场景：`Main.tscn`
- 物理频率：120 ticks/s
- 渲染器：Forward Plus

---

## 2. 快速上手

| 按键 | 功能 |
|------|------|
| WASD | 移动 |
| 空格 | 跳跃 |
| Enter | 重新开始（游戏结束后） |

---

## 3. 核心架构

```
Main (Node)
├── Player (CharacterBody3D)     ← 玩家
├── SpawnPath (Path3D)           ← 怪物生成路径
├── MobTimer (Timer)             ← 定时生成怪物
├── UserInterface (Control)      ← UI 层
│   ├── ScoreLabel (Label)
│   └── Retry (Button)
└── MusicPlayer (自动加载)       ← 背景音乐
```

---

## 4. 文件逐层导读

### `Main.cs` — 游戏主控 ⭐

`Main.cs:3` 继承 `Node`，管理游戏生命周期。

- `OnMobTimerTimeout()` (`Main.cs:23`) — 在 `SpawnPath` 上随机位置生成怪物
- `OnPlayerHit()` (`Main.cs:45`) — 停止生成计时器，显示重试按钮

```csharp
Mob mob = MobScene.Instantiate<Mob>();
PathFollow3D mobSpawnLocation = GetNode<PathFollow3D>("SpawnPath/SpawnLocation");
mobSpawnLocation.ProgressRatio = GD.Randf();
mob.Initialize(mobSpawnLocation.Position, playerPosition);
```

### `Player.cs` — 玩家控制

`Player.cs:3` 继承 `CharacterBody3D`，处理 3D 移动、跳跃和踩扁怪物。

- `_PhysicsProcess()` (`Player.cs:24`) — 核心物理逻辑
- 移动：读取 WASD 输入，在 XZ 平面移动
- 跳跃：`IsOnFloor()` 检测地面，`JumpImpulse` 提供向上速度
- 踩扁检测：遍历 `GetSlideCollision()`，检测碰撞对象是否为 `Mob`，且法线朝上

```csharp
if (collision.GetCollider() is Mob mob)
{
    if (Vector3.Up.Dot(collision.GetNormal()) > 0.1f)
    {
        mob.Squash();
        _targetVelocity.Y = BounceImpulse;
    }
}
```

- `Die()` (`Player.cs:109`) — 发射 `Hit` 信号后销毁

### `Mob.cs` — 怪物逻辑

`Mob.cs:3` 继承 `CharacterBody3D`。

- `Initialize()` (`Mob.cs:22`) — 设置初始位置，朝向玩家，随机偏移 ±45 度
- `Squash()` (`Mob.cs:42`) — 发射 `Squashed` 信号后销毁
- `OnVisibleOnScreenNotifierScreenExited()` (`Mob.cs:49`) — 离开视野时销毁

### `ScoreLabel.cs` — 分数显示

`ScoreLabel.cs:3` 继承 `Label`，监听 `Squashed` 信号更新分数。

---

## 5. 场景树全景

```
Main (Node)
├── Player (CharacterBody3D)
│   ├── Pivot (Node3D)
│   │   ├── Player (MeshInstance3D)
│   │   └── AnimationPlayer
│   ├── CollisionShape3D
│   └── MobDetector (Area3D)
├── SpawnPath (Path3D)
│   └── SpawnLocation (PathFollow3D)
├── MobTimer (Timer)
├── WorldEnvironment
├── DirectionalLight3D
├── Ground (StaticBody3D)
│   └── CollisionShape3D
└── UserInterface (Control)
    ├── ScoreLabel (Label)
    └── Retry (Button)
```
