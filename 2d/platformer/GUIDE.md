# Platformer 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

一个相对完整的像素风 2D 平台游戏。玩家可以跳跃、行走斜坡、射击、收集金币、击败敌人。支持单人模式和分屏双人模式。

## 2. 快速上手

运行 `game_singleplayer.tscn`，A/D 移动，W/空格跳跃，Z/空格射击。Esc 暂停，F11 全屏。

## 3. 核心架构

```
src/
├── player/
│   ├── player.gd      ← 玩家控制器
│   ├── gun.gd         ← 枪械
│   └── bullet.gd      ← 子弹
├── enemy/
│   └── enemy.gd       ← 敌人
├── level/
│   ├── level.gd       ← 关卡管理
│   └── coin.gd        ← 金币
└── gui/
    ├── pause_menu.gd  ← 暂停菜单
    └── coins_counter.gd ← 金币计数器
```

## 4. 文件逐层导读

### `player/player.gd` — 玩家控制器 ⭐

```gdscript
extends CharacterBody2D

const WALK_SPEED = 300.0
const JUMP_VELOCITY = -725.0
const TERMINAL_VELOCITY = 700
```

**双跳系统：**
```gdscript
func try_jump():
    if is_on_floor():
        jump_sound.pitch_scale = 1.0
    elif _double_jump_charged:
        _double_jump_charged = false
        velocity.x *= 2.5  # 二段跳时水平加速
        jump_sound.pitch_scale = 1.5
    else:
        return
    velocity.y = JUMP_VELOCITY
```

**斜坡处理：**
```gdscript
floor_stop_on_slope = not platform_detector.is_colliding()
```

**分屏支持：** 通过 `action_suffix` 属性区分玩家 1 和玩家 2 的输入。

### `player/gun.gd` — 枪械

```gdscript
func shoot(direction: float = 1.0) -> bool:
    if not timer.is_stopped():
        return false  # 冷却中
    var bullet := BULLET_SCENE.instantiate() as Bullet
    bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)
    bullet.set_as_top_level(true)  # 脱离枪的局部坐标
    add_child(bullet)
```

### `enemy/enemy.gd` — 敌人

```gdscript
enum State { WALKING, DEAD }
```

- 左右巡逻，使用 `RayCast2D` 检测悬崖和墙壁
- 被子弹击中后进入 DEAD 状态

### `level/level.gd` — 关卡

设置所有玩家的摄像机边界：
```gdscript
for child in get_children():
    if child is Player:
        var camera = child.get_node("Camera")
        camera.limit_left = LIMIT_LEFT
```

## 5. 关键概念详解

### CharacterBody2D 斜坡行走

`floor_stop_on_slope` 属性控制角色在斜坡上是否停止。当 `PlatformDetector`（RayCast2D）检测到平台边缘时禁用此属性，允许角色走下平台。

### 分屏模式

`game_splitscreen.gd` 为每个玩家创建独立的 `Viewport`，每个视口有自己的摄像机。输入通过 `action_suffix`（`_p1`/`_p2`）区分。

## 6. 场景树全景

```
Game (Node)
├── Level (Node2D)
│   ├── Player (CharacterBody2D)
│   │   ├── Sprite2D
│   │   │   └── Gun (Marker2D)
│   │   ├── AnimationPlayer
│   │   ├── Camera2D
│   │   ├── PlatformDetector (RayCast2D)
│   │   └── ShootAnimation (Timer)
│   ├── Enemy (CharacterBody2D)
│   ├── Coin (Area2D)
│   └── ...
└── InterfaceLayer (CanvasLayer)
    └── PauseMenu (Control)
        ├── CoinsCounter
        └── VBoxContainer (Buttons)
```

## 7. 如何扩展

- 添加新敌人类型（飞行、射击等）
- 增加关卡：创建新的 `.tscn` 文件，在 `game.gd` 中添加切换逻辑
- 添加生命值系统
