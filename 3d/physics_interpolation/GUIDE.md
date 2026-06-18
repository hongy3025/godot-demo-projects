# 物理插值 - 源代码导读

> 本文档面向 Godot 新手，剖析物理插值演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Physics Interpolation**（`project.godot` 中 `config/name`）

展示 3D 中的物理插值（固定时间步长插值），包含三种摄像机模式：第一人称、第三人称、固定视角。

主场景：`uid://bj5w87j8wwnsl`

## 2. 快速上手

WASD 移动，空格跳跃，鼠标左键射击。**Tab** 切换摄像机模式，**T** 切换物理插值开关。物理 tick 率设为 20（极低），以突显插值效果。

## 3. 核心架构

```
main.tscn
├── Player (CharacterBody3D)
│   ├── CollisionShape3D
│   ├── Camera3D (第一人称)
│   └── Gun
├── Level (StaticBody3D)
├── Bullets
└── UI
```

## 4. 文件逐层导读

### `player.gd` — 玩家控制

继承 `CharacterBody3D`。

**关键特性：**
- 支持三种摄像机模式切换
- 物理插值开关（T 键）
- 射击系统

### `bullet.gd` — 子弹脚本

子弹物理逻辑，展示插值对快速移动物体的影响。

### 物理插值原理

```
物理 tick (20 FPS)    →    渲染帧 (可变 FPS)
    │                          │
    └──── 插值 ────────────────┘
        平滑过渡
```

**项目设置：**
```ini
[physics]
common/physics_ticks_per_second=20
common/physics_interpolation=true
```

物理 tick 率设为 20（极低），如果不启用插值，运动将非常卡顿。启用插值后，渲染帧在物理 tick 之间进行插值，使运动看起来平滑。

### 注意事项

- 插值会增加延迟
- 传送物体时需要调用 `reset_physics_interpolation()`
- 使用 Compatibility 渲染器
