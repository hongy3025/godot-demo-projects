# Pong with C# - 源代码导读

> 本文档面向 Godot 新手，展示如何使用 C# 实现经典 Pong 游戏，重点学习信号（Signal）的使用。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [场景树全景](#5-场景树全景)

---

## 1. 项目概述

**Pong with C#** 是一个双人同屏 Pong 游戏，使用 `Area2D` 碰撞检测和信号机制实现。

- 语言：C#
- 主场景：`pong.tscn`
- 窗口大小：640×400

---

## 2. 快速上手

| 按键 | 功能 |
|------|------|
| W/A | 左拍上移 |
| S/D | 左拍下移 |
| 上/左方向键 | 右拍上移 |
| 下/右方向键 | 右拍下移 |

---

## 3. 核心架构

```
Pong (Node2D)
├── Left (Paddle)        ← 左方球拍
├── Right (Paddle)       ← 右方球拍
├── Ball (Area2D)        ← 球
├── Ceiling (Area2D)     ← 天花板（反弹）
├── Floor (Area2D)       ← 地板（反弹）
├── WallLeft (Area2D)    ← 左墙（得分重置）
├── WallRight (Area2D)   ← 右墙（得分重置）
└── ScoreLabel (Label)   ← 得分显示
```

---

## 4. 文件逐层导读

### `Paddle.cs` — 球拍控制 ⭐

`Logic/Paddle.cs:4` 继承 `Area2D`，根据节点名称动态绑定输入动作。

```csharp
string name = Name.ToString().ToLower();
_up = name + "_move_up";    // "left_move_up" 或 "right_move_up"
_down = name + "_move_down";
_ballDir = name == "left" ? 1 : -1;
```

- `_Process()` (`Paddle.cs:21`) — 读取输入，移动球拍，限制在屏幕范围内
- `OnAreaEntered()` (`Paddle.cs:31`) — 球碰到球拍时改变球的方向，增加随机 Y 分量

### `Ball.cs` — 球逻辑

`Logic/Ball.cs:3` 继承 `Area2D`。

- `_Process()` (`Ball.cs:17`) — 每帧沿 `direction` 方向移动，速度逐渐增加
- `Reset()` (`Ball.cs:23`) — 重置位置和速度

```csharp
public Vector2 direction = Vector2.Left;
// 公开字段，由 Paddle 和 CeilingFloor 直接修改
```

### `CeilingFloor.cs` — 上下边界反弹

`Logic/CeilingFloor.cs:3` 继承 `Area2D`，通过 `_bounceDirection` 导出变量控制反弹方向。

```csharp
ball.direction = (ball.direction + new Vector2(0, _bounceDirection)).Normalized();
```

### `Wall.cs` — 左右边界得分

`Logic/Wall.cs:3` 继承 `Area2D`，球碰到墙壁时调用 `ball.Reset()`。

---

## 5. 场景树全景

```
Pong (Node2D)
├── Left (Paddle)
│   ├── CollisionShape2D
│   └── Sprite2D
├── Right (Paddle)
│   ├── CollisionShape2D
│   └── Sprite2D
├── Ball (Area2D)
│   ├── CollisionShape2D
│   └── Sprite2D
├── Ceiling (Area2D)  ← 天花板
├── Floor (Area2D)    ← 地板
├── WallLeft (Area2D) ← 左墙
├── WallRight (Area2D)← 右墙
├── Separator (Sprite2D) ← 中线
└── ScoreLabel (Label)
```
