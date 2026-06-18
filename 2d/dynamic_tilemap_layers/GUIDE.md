# Dynamic TileMap Layers - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 `TileMapLayer._tile_data_runtime_update()` 在运行时动态禁用瓦片地图的碰撞，实现"假墙"效果——玩家进入秘密区域时，墙壁变为半透明并可穿过。

## 2. 快速上手

运行 `world.tscn`，WASD 移动，空格跳跃。走到右侧秘密区域，墙壁变为半透明并失去碰撞。

## 3. 核心架构

```
world.tscn
├── Player (CharacterBody2D)  ← 玩家
├── TileMapLayer (Ground)     ← 地面层（有碰撞）
├── TileMapLayer (Secret)     ← 秘密墙壁层（动态碰撞）
│   └── SecretDetector (Area2D) ← 检测玩家进入
├── Princess (StaticBody2D)   ← 终点
└── WinText (Label)
```

## 4. 文件逐层导读

### `player/player.gd` — 玩家控制器

与 `kinematic_character` 项目相同的 `CharacterBody2D` 控制器：
- 水平力 `WALK_FORCE = 600`，最大速度 `200`
- 跳跃速度 `200`，重力从 ProjectSettings 读取
- 使用 `move_and_slide()` 处理碰撞

### `level/tile_map.gd` — 动态瓦片地图 ⭐

**核心机制：** 运行时修改瓦片数据。

```gdscript
func _tile_data_runtime_update(_coords, tile_data):
    tile_data.set_collision_polygons_count(0, 0)  # 移除碰撞
```

**透明度动画：**
```gdscript
func _process(delta):
    if player_in_secret:
        layer_alpha = move_toward(layer_alpha, 0.3, delta)
        self_modulate = Color(1, 1, 1, layer_alpha)
```

**工作流程：**
1. `SecretDetector`（Area2D）检测玩家进入/离开
2. 设置 `player_in_secret` 标志
3. `_process()` 中平滑过渡透明度
4. `_tile_data_runtime_update()` 持续移除该层的碰撞

## 5. 关键概念详解

### `_tile_data_runtime_update()`

Godot 4.3+ 的 `TileMapLayer` 方法，每帧在渲染前调用，允许修改瓦片的运行时属性（碰撞、纹理等）而不影响原始瓦片数据。

### 碰撞层禁用

在 Godot 4.3+ 中，`TileMapLayer` 已有 Inspector 中的碰撞开关。此项目展示的是通过代码实现的方式，适用于需要更精细控制的场景。

## 6. 场景树全景

```
World (Node2D)
├── Player (CharacterBody2D)
│   ├── CollisionShape2D
│   └── Sprite2D
├── TileMapLayer (Ground)
├── TileMapLayer (Secret)
│   └── SecretDetector (Area2D)
│       └── CollisionShape2D
├── Princess (StaticBody2D)
│   └── CollisionShape2D
└── WinText (Label)
```

## 7. 如何扩展

- 添加多个秘密区域，每个使用不同的透明度值
- 在 `_tile_data_runtime_update()` 中动态切换瓦片纹理
- 使用 `Custom Data Layers` 标记特定瓦片类型，实现选择性碰撞移除
