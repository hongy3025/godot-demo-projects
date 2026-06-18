# 碾压怪物 (Squash the Creeps) - 源代码导读

> 本文档面向 Godot 新手，剖析"你的第一个 3D 游戏"教程完成版的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Squash the Creeps (3D)**（`project.godot` 中 `config/name`）

一个简单的 3D 游戏：玩家移动和跳跃碾压敌人，每碾压一个得 1 分。这是官方教程"你的第一个 3D 游戏"的完成版本。

主场景：`Main.tscn`

## 2. 快速上手

WASD/方向键移动，空格/鼠标右键跳跃。跳到敌人头顶将其碾压得分。被敌人碰到则游戏结束，按 Enter 重新开始。

## 3. 核心架构

```
Main.tscn
├── Player (CharacterBody3D)  ← 玩家
│   ├── CollisionShape3D
│   ├── MeshInstance3D
│   ├── AnimationPlayer
│   ├── Pivot (Node3D)
│   │   └── PlayerCamera
│   └── MobDetector (Area3D)  ← 碰撞检测
├── SpawnPath (Path3D)
│   └── SpawnLocation (PathFollow3D)
├── MobTimer                  ← 生成计时器
├── DirectionalLight3D
├── WorldEnvironment
└── UserInterface (CanvasLayer)
    ├── ScoreLabel
    ├── Message
    └── Retry
```

## 4. 文件逐层导读

### `Player.gd` — 玩家控制

继承 `CharacterBody3D`。

**关键属性：**
```gdscript
@export var speed = 14
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var fall_acceleration = 75
```

**`_physics_process()` 核心逻辑：**
1. 读取 WASD 输入，设置方向
2. 使用 `Basis.looking_at(direction)` 旋转角色朝向
3. 设置 `velocity.x/z` 并应用重力
4. 调用 `move_and_slide()`
5. 遍历碰撞检测碾压敌人：
```gdscript
for index in range(get_slide_collision_count()):
    var collision = get_slide_collision(index)
    if collision.get_collider().is_in_group(&"mob"):
        if Vector3.UP.dot(collision.get_normal()) > 0.1:
            mob.squash()
            velocity.y = bounce_impulse
```

### `Mob.gd` — 敌人

继承 `CharacterBody3D`。

**关键方法：**
```gdscript
func initialize(start_position, player_position):
    look_at_from_position(start_position, target, Vector3.UP)
    rotate_y(randf_range(-PI / 4, PI / 4))  # 随机偏移方向
    velocity = Vector3.FORWARD * random_speed
    velocity = velocity.rotated(Vector3.UP, rotation.y)
```

### `Main.gd` — 游戏主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_on_mob_timer_timeout()` | 在 SpawnPath 上随机位置生成敌人 |
| `_on_player_hit()` | 游戏结束，停止生成，显示重试按钮 |

### `ScoreLabel.gd` — 分数显示

更新和显示当前分数。

### 游戏循环

```
生成敌人 → 玩家移动跳跃 → 碾压敌人（得分）→ 碰到敌人（游戏结束）→ 重试
```
