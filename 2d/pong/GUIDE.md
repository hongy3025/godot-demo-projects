# Pong with GDScript - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

经典 Pong 游戏的 Godot 实现。展示信号（Signal）的最佳实践——所有游戏对象使用 `Area2D`，通过信号通信。

## 2. 快速上手

运行 `pong.tscn`，左玩家 W/S 移动，右玩家上/下方向键移动。球碰到上下边界反弹，碰到左右边界得分重置。

## 3. 核心架构

```
pong.tscn
├── Ball (Area2D)         ← 球
├── LeftPaddle (Area2D)   ← 左拍
├── RightPaddle (Area2D)  ← 右拍
├── TopWall (Area2D)      ← 上墙
├── BottomWall (Area2D)   ← 下墙
├── LeftWall (Area2D)     ← 左墙（得分）
└── RightWall (Area2D)    ← 右墙（得分）
```

**所有节点都是 `Area2D`**，没有使用 `RigidBody2D` 或 `CharacterBody2D`。

## 4. 文件逐层导读

### `logic/ball.gd` — 球

```gdscript
extends Area2D

const DEFAULT_SPEED = 100.0
var _speed := DEFAULT_SPEED
var direction := Vector2.LEFT

func _process(delta):
    _speed += delta * 2  # 逐渐加速
    position += _speed * delta * direction

func reset():
    direction = Vector2.LEFT
    position = _initial_pos
    _speed = DEFAULT_SPEED
```

- 速度随时间递增（`_speed += delta * 2`），增加难度
- `direction` 由碰撞时其他节点修改

### `logic/paddle.gd` — 球拍

```gdscript
func _ready():
    var n := String(name).to_lower()
    _up = n + "_move_up"
    _down = n + "_move_down"

func _process(delta):
    var input := Input.get_action_strength(_down) - Input.get_action_strength(_up)
    position.y = clamp(position.y + input * MOVE_SPEED * delta, 16, _screen_size_y - 16)

func _on_area_entered(area):
    if area.name == "Ball":
        area.direction = Vector2(_ball_dir, randf() * 2 - 1).normalized()
```

- 输入动作名根据节点名动态生成（`left_move_up` / `right_move_up`）
- 碰撞时修改球的 `direction`，加入随机 Y 分量

### `logic/wall.gd` — 墙壁

```gdscript
func _on_wall_area_entered(area):
    if area.name == "Ball":
        area.reset()  # 球出界，重置
```

### `logic/ceiling_floor.gd` — 天花板/地板

```gdscript
func _on_area_entered(area):
    if area.name == "Ball":
        area.direction = (area.direction + Vector2(0, _bounce_direction)).normalized()
```

## 5. 关键概念详解

### Area2D 信号通信

项目展示了纯信号驱动的游戏架构：
- 球拍碰撞 → 修改球方向
- 墙壁碰撞 → 重置球
- 天花板/地板碰撞 → 反弹球

没有使用 `_physics_process()` 做碰撞检测，完全依赖 `area_entered` 信号。

### 输入映射

输入动作使用 `left_move_up`/`left_move_down` 和 `right_move_up`/`right_move_down` 的命名约定，支持双人键盘和手柄。

## 6. 场景树全景

```
Pong (Node2D)
├── Ball (Area2D)
│   └── CollisionShape2D
├── LeftPaddle (Area2D)
│   ├── CollisionShape2D
│   └── Sprite2D
├── RightPaddle (Area2D)
│   ├── CollisionShape2D
│   └── Sprite2D
├── TopWall (Area2D)
├── BottomWall (Area2D)
├── LeftWall (Area2D)
└── RightWall (Area2D)
```

## 7. 如何扩展

- 添加计分系统：在墙壁碰撞时更新 UI 分数
- 添加 AI 对手：让右拍自动追踪球的位置
- 添加音效：在碰撞时播放 `AudioStreamPlayer2D`
