# 体素游戏 (Voxel Game) - 源代码导读

> 本文档面向 Godot 新手，剖析体素游戏演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Voxel Game**（`project.godot` 中 `config/name`）

一个极简的第一人称体素游戏，灵感来自 Minecraft。使用 GDScript 和 Godot 内置工具实现。

主场景：`menu/main/main_menu.tscn`

## 2. 快速上手

WASD 移动，空格跳跃，Shift 奔跑。鼠标左键破坏方块，右键放置方块，滚轮/Q/E 切换方块类型，中键拾取方块。Esc 暂停。

## 3. 核心架构

```
voxel/
├── menu/
│   ├── main/                 ← 主菜单
│   ├── options/              ← 设置菜单
│   └── ingame/               ← 游戏内菜单
├── player/
│   └── player.gd             ← 玩家控制
├── world/
│   ├── voxel_world.gd        ← 体素世界管理
│   ├── chunk.gd              ← 区块
│   ├── terrain_generator.gd  ← 地形生成器
│   └── environment.gd        ← 环境
├── settings.gd               ← 设置单例
└── ...
```

## 4. 文件逐层导读

### `world/voxel_world.gd` — 体素世界管理 ⭐

**核心类：** `VoxelWorld`，继承 `Node`。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_process()` | 每帧检查玩家位置，生成/删除区块 |
| `get_block_in_chunk()` | 获取区块中方块的 ID |
| `set_block_global_position()` | 设置全局坐标的方块，触发邻接区块重建 |
| `clean_up()` | 清理所有区块 |
| `_delete_far_away_chunks()` | 删除远离玩家的区块 |

**区块生成逻辑：**
```gdscript
# 每帧生成一个区块，避免卡顿
for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance):
    for y in range(player_chunk.y - render_distance, player_chunk.y + render_distance):
        for z in range(player_chunk.z - render_distance, player_chunk.z + render_distance):
            var chunk := Chunk.new(chunk_position)
            _chunks[chunk_position] = chunk
            add_child(chunk)
            chunk.try_initial_generate_mesh(_chunks)
            return  # 每帧只生成一个
```

### `world/chunk.gd` — 区块

**关键特性：**
- 使用 `SurfaceTool` 构建网格
- 每个方块有独立的 `CollisionShape3D`
- 网格生成在单独线程中执行
- 碰撞生成在主线程中

### `world/terrain_generator.gd` — 地形生成器

两种地形类型：随机方块和平坦草地。

### `player/player.gd` — 玩家控制

第一人称控制器，使用 `RayCast3D` 检测方块放置/破坏位置。

### `settings.gd` — 设置单例

AutoLoad 单例，保存和加载渲染距离、雾开关等设置。

### 架构局限

> 使用 GDScript 和内置工具实现体素游戏性能有限。建议使用 Zylann 的体素模块：https://github.com/Zylann/godot_voxel
