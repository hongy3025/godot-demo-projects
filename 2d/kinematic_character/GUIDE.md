# Kinematic Character 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 `CharacterBody2D` 创建运动学角色控制器。角色可以移动、跳跃、受重力影响、在移动平台上站立、穿过单向碰撞平台。

## 2. 快速上手

运行 `world.tscn`，A/D 左右移动，W/空格/上方向键跳跃。走到右侧公主处触发胜利。

## 3. 核心架构

```
world.tscn
├── Player (CharacterBody2D)  ← 玩家
├── Platforms (StaticBody2D)  ← 静态平台
├── MovingPlatform (AnimatableBody2D) ← 移动平台
├── OneWayPlatform (StaticBody2D) ← 单向平台
└── Princess (StaticBody2D)   ← 终点
    └── WinText (Label)
```

## 4. 文件逐层导读

### `player/player.gd` — 玩家控制器 ⭐

```gdscript
extends CharacterBody2D

const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
```

**水平移动：** 使用力（`WALK_FORCE`）加速，用 `move_toward()` 减速，最后 `clamp()` 限制最大速度。

**垂直移动：** 每帧累加重力，`move_and_slide()` 后检测 `is_on_floor()` 决定是否允许跳跃。

**关键代码：**
```gdscript
velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)  # 减速
velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)  # 限速
velocity.y += gravity * delta  # 重力
move_and_slide()
if is_on_floor() and Input.is_action_just_pressed(&"jump"):
    velocity.y = -JUMP_SPEED
```

### `level/princess.gd` — 胜利检测

```gdscript
func _on_body_entered(body):
    if body.name == "Player":
        $"../WinText".show()
```

## 5. 关键概念详解

### CharacterBody2D 特性

- `move_and_slide()`：自动处理碰撞响应和滑动
- `is_on_floor()`：检测是否站在地面上
- `velocity`：内置速度属性，`move_and_slide()` 会修改它

### 移动平台支持

`AnimatableBody2D` 作为移动平台时，`CharacterBody2D` 站在上面会自动跟随移动，无需额外代码。

### 单向平台

通过设置 `CollisionShape2D` 的 `one_way_collision` 属性实现，角色可以从下方穿过但站在上方。

## 6. 场景树全景

```
World (Node2D)
├── Player (CharacterBody2D)
│   └── CollisionShape2D
├── Platforms (StaticBody2D)
│   └── CollisionShape2D
├── MovingPlatform (AnimatableBody2D)
│   ├── CollisionShape2D
│   └── AnimationPlayer
├── OneWayPlatform (StaticBody2D)
│   └── CollisionShape2D
└── Princess (StaticBody2D)
    ├── CollisionShape2D
    ├── Area2D (detector)
    └── WinText (Label)
```

## 7. 如何扩展

- 添加双跳：在跳跃时检测 `not is_on_floor()` 允许第二次跳跃
- 添加冲刺：按 Shift 时临时提高 `WALK_MAX_SPEED`
- 添加动画：根据 `velocity.x` 切换 Sprite2D 的动画
