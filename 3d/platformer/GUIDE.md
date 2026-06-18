# 平台游戏 3D - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 平台游戏演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Platformer 3D**（`project.godot` 中 `config/name`）

使用 `CharacterBody3D` 的 3D 平台游戏演示，包含完整的游戏机制：移动、跳跃、射击、收集金币、敌人。

主场景：`game.tscn`

## 2. 快速上手

WASD 移动，空格跳跃，鼠标左键射击，R 重置位置。收集金币，击败敌人。

## 3. 核心架构

```
game.tscn
├── Stage (Node3D)            ← 关卡
│   ├── StaticBody3D          ← 地形
│   └── Coins / Enemies
├── Player (CharacterBody3D)
│   ├── CollisionShape3D
│   ├── Target/Camera3D
│   ├── Skeleton (Node3D)
│   │   └── AnimationTree
│   └── Bullet
├── DirectionalLight3D
└── UI (CanvasLayer)
```

## 4. 文件逐层导读

### `player/player.gd` — 玩家控制

继承 `CharacterBody3D`，类名 `Player`。

**关键常量：**
```gdscript
const MAX_SPEED = 6.0
const JUMP_VELOCITY = 12.5
const ACCEL = 14.0
const DEACCEL = 14.0
const BULLET_SPEED = 20.0
```

**`_physics_process()` 核心逻辑：**
1. 重力应用：`velocity += gravity * delta`
2. 输入处理：摄像机空间方向转换
3. 水平移动：加速/减速插值
4. 角色朝向：`adjust_facing()` 平滑旋转
5. 跳跃：`is_on_floor()` 检测 + 跳跃速度
6. 射击：实例化子弹，设置速度
7. 动画：通过 `AnimationTree` 控制混合

**动画系统：**
```gdscript
_animation_tree[&"parameters/run/blend_amount"] = horizontal_speed / MAX_SPEED
_animation_tree[&"parameters/state/blend_amount"] = anim  # FLOOR / AIR
_animation_tree[&"parameters/gun/blend_amount"] = minf(shoot_blend, 1.0)
```

### `enemy/enemy.gd` — 敌人 AI

简单的敌人巡逻和追击逻辑。

### `coin/coin.gd` — 金币

收集逻辑，与玩家碰撞后增加金币计数。

### `stage/stage.gd` — 关卡管理

管理关卡中的物体和事件。

### `player/bullet/bullet.gd` — 子弹

子弹飞行和碰撞逻辑。

### `player/follow_camera.gd` — 跟随摄像机

第三人称跟随摄像机，平滑跟随玩家。
