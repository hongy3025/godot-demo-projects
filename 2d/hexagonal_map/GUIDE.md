# Hexagonal Game - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 Godot 的六边形 `TileMap` 和 `TileSet`。玩家角色在六边形地图上移动，移动适配六边形的几何特性。

## 2. 快速上手

运行 `map.tscn`，WASD 控制巨魔在六边形地图上移动。

## 3. 核心架构

```
map.tscn
├── TileMapLayer           ← 六边形瓦片地图
└── Troll (CharacterBody2D) ← 玩家角色
    ├── CollisionShape2D
    └── Sprite2D
```

## 4. 文件逐层导读

### `troll.gd` — 玩家移动

```gdscript
const TAN30DEG = tan(deg_to_rad(30))
```

**六边形适配的关键：** 垂直移动速度乘以 `tan(30°)`，使对角移动在六边形网格上看起来自然。

```gdscript
motion.y *= TAN30DEG
velocity += motion.normalized() * MOTION_SPEED
velocity *= FRICTION_FACTOR  # 摩擦力
move_and_slide()
```

- `MOTION_SPEED = 30`：移动速度
- `FRICTION_FACTOR = 0.89`：每帧摩擦力系数（指数衰减）

## 5. 关键概念详解

### 六边形瓦片地图

Godot 的 `TileMapLayer` 支持六边形瓦片布局。TileSet 中需要配置六边形的形状和尺寸。六边形有两种常见朝向：平顶（flat-top）和尖顶（pointy-top），本项目使用尖顶六边形。

### tan(30°) 的作用

在六边形网格中，垂直方向的相邻瓦片中心距离与水平方向不同。乘以 `tan(30°)` 使垂直移动速度与网格几何匹配，避免对角移动看起来"太快"。

## 6. 场景树全景

```
Map (Node2D)
├── TileMapLayer
└── Troll (CharacterBody2D)
    ├── CollisionShape2D
    └── Sprite2D
```

## 7. 如何扩展

- 在 TileSet 中添加更多六边形瓦片纹理
- 实现 A* 寻路（六边形网格的邻居计算与方形不同）
- 添加建筑/单位放置逻辑
