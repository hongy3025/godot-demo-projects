# 刚体角色 3D - 源代码导读

> 本文档面向 Godot 新手，剖析刚体角色演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**RigidBody Character 3D**（`project.godot` 中 `config/name`）

使用胶囊体作为角色的 3D 刚体角色演示。立方体作为 RigidBody 从上方生成，展示与玩家的物理交互。

主场景：`level.tscn`

## 2. 快速上手

WASD 移动，空格跳跃，R 重置位置。推挤场景中的立方体。

## 3. 核心架构

```
level.tscn
├── Cubio (RigidBody3D)       ← 玩家角色（刚体）
│   ├── CollisionShape3D
│   ├── Target (Node3D)
│   │   └── Camera3D
│   ├── MeshInstance3D
│   └── ShapeCast3D           ← 地面检测
├── Level (StaticBody3D)      ← 关卡地形
├── Spawner                   ← 立方体生成器
└── DirectionalLight3D
```

## 4. 文件逐层导读

### `player/cubio.gd` — 玩家控制

继承 `RigidBody3D`（与 `kinematic_character` 使用 `CharacterBody3D` 不同）。

**关键常量：**
```gdscript
const MAX_SPEED = 3.5
const JUMP_SPEED = 6.5
const ACCELERATION = 4
const DECELERATION = 4
```

**`_physics_process()` 核心逻辑：**
1. 获取 WASD 输入方向
2. 使用 `apply_central_impulse()` 施加力来移动（而非 `move_and_slide()`）
3. 使用 `ShapeCast3D` 检测地面（而非 `RayCast3D`）
4. 检测 `is_on_floor()` 和跳跃输入

**ShapeCast3D 的优势：**
```gdscript
# ShapeCast3D 有体积，比无限细的 RayCast3D 更可靠
# 可以更准确地检测玩家是否站在边缘或角落上方
```

### `level.gd` — 关卡管理

管理立方体生成器，定期从上方掉落 RigidBody 立方体。

### 刚体 vs 运动学角色

| 特性 | CharacterBody3D | RigidBody3D |
|------|----------------|-------------|
| 移动方式 | `move_and_slide()` | `apply_central_impulse()` |
| 物理交互 | 仅碰撞 | 可推动其他物体 |
| 适用场景 | 平台游戏 | 需要物理交互的角色 |
