# Isometric Game - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示传统的等距视角（Isometric View）游戏实现。角色在地牢中移动，具有 8 方向动画和深度排序（Y-sort），角色在物体前后时正确遮挡。

## 2. 快速上手

运行 `dungeon.tscn`，WASD 控制哥布林在地牢中移动，观察角色在墙壁/柱子前后的遮挡效果。

## 3. 核心架构

```
dungeon.tscn
├── Dungeon (Node2D)
│   ├── TileMapLayer       ← 等距瓦片地图
│   ├── Walls (StaticBody2D) ← 墙壁碰撞
│   ├── Pillars (StaticBody2D) ← 柱子碰撞
│   └── Player (CharacterBody2D)
│       ├── CollisionShape2D
│       └── Sprite2D (AnimatedSprite2D)
```

**关键特性：** `TileMapLayer` 启用 Y-sort，使角色在瓦片前后时正确排序。

## 4. 文件逐层导读

### `player/goblin.gd` — 玩家控制 ⭐

**8 方向动画系统：**
```gdscript
var anim_directions = {
    "idle": [
        ["side_right_idle", false],
        ["45front_right_idle", false],
        ["front_idle", false],
        ...
    ],
    "walk": [...]
}
```

**方向计算：**
```gdscript
func update_animation(anim_set):
    var angle = rad_to_deg(last_direction.angle()) + 22.5
    var slice_dir = floor(angle / 45)  # 8 方向 = 360° / 45°
    $Sprite2D.play(anim_directions[anim_set][slice_dir][0])
```

- 移动向量角度 + 22.5° 偏移，使方向边界对齐 8 个扇区
- `slice_dir` 取值 0~7，对应 8 个方向

**等距移动适配：**
```gdscript
motion.y /= 2  # 等距视角下 Y 轴移动减半
```

## 5. 关键概念详解

### 等距投影

等距视角中，X 和 Y 轴在屏幕上呈 120° 夹角。Y 轴移动在屏幕上看起来是斜向的，因此速度需要调整（`motion.y /= 2`）使对角移动速度一致。

### Y-Sort 深度排序

`TileMapLayer` 的 Y-sort 功能根据节点的 Y 坐标自动调整绘制顺序。Y 值大的节点（靠近屏幕底部）后绘制，覆盖 Y 值小的节点，实现正确的遮挡效果。

### 碰撞系统

墙壁和柱子使用 `StaticBody2D` + `CollisionPolygon2D`，碰撞体位于物体底部（与地面接触的位置），使角色围绕物体滑动。

## 6. 场景树全景

```
Dungeon (Node2D)
├── TileMapLayer (Y-sort enabled)
├── Walls (StaticBody2D)
│   └── CollisionPolygon2D
├── Pillars (StaticBody2D)
│   └── CollisionPolygon2D
└── Player (CharacterBody2D)
    ├── CollisionShape2D
    └── Sprite2D (AnimatedSprite2D)
```

## 7. 如何扩展

- 在 `anim_directions` 中添加更多动画集（攻击、受伤等）
- 添加 `PointLight2D` 实现动态光影
- 扩展 TileSet 添加更多等距瓦片类型
