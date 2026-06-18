# 2.5D Demo with C# - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。本项目是 GDScript 版 2.5D Demo 的 C# 移植版。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

**2.5D Demo with C#** 是 Godot 官方 2.5D 技术演示的 C# 移植版。核心思路：用 3D 物理引擎做碰撞计算，用 2D 精灵做渲染，通过投影矩阵将 3D 坐标映射到 2D 屏幕。

- 使用 C# 编写（`addons/node25d-cs/` 为 C# 插件）
- 支持 6 种视角模式一键切换
- 主场景：`assets/demo_scene.tscn`，立方体演示：`assets/cube/cube.tscn`

---

## 2. 快速上手

在 Godot Mono 版中打开 `project.godot`，直接运行主场景。

| 按键 | 功能 |
|------|------|
| WASD | 移动 |
| 空格 | 跳跃 |
| U/I/O/J/K/L | 切换 6 种视角模式 |
| T | 切换等距操控 |
| R | 重置位置 |
| C | 切换到立方体演示 |

---

## 3. 核心架构

```
2D 渲染层 (Sprite2D / Camera2D / YSort25D)
       ↑
2.5D 投影层 (Node25D) — 3D坐标 → 基向量投影 → 2D全局坐标
       ↑
3D 物理层 (CharacterBody3D / StaticBody3D)
```

核心公式：`2D位置 = 3D坐标.x × basisX + 3D坐标.y × basisY + 3D坐标.z × basisZ`，缩放因子 `SCALE = 32`。

---

## 4. 文件逐层导读

### 4.1 核心插件 (`addons/node25d-cs/`)

#### `Node25D.cs` — 核心投影节点 ⭐

`addons/node25d-cs/Node25D.cs` 是整个项目的基石。所有 2.5D 对象都继承此类。

- `Node25DReady()` — 初始化，获取第一个子节点作为 3D 节点，设置默认 45 度基向量
- `Node25DProcess()` — 每帧执行 3D→2D 投影计算
- `SetViewMode(int)` — 切换 6 种视角模式，本质是修改三个基向量的值

6 种视角模式：
| 模式 | basisX | basisY | basisZ |
|------|--------|--------|--------|
| 0 - 45度 | (1,0) | (0,-0.707) | (0,0.707) |
| 1 - 等距 | (0.866,0.5) | (0,-1) | (-0.866,0.5) |
| 2 - 俯视 | (1,0) | (0,0) | (0,1) |
| 3 - 正面 | (1,0) | (0,-1) | (0,0) |
| 4 - 斜Y | (1,0) | (-0.707,-0.707) | (0,1) |
| 5 - 斜Z | (1,0) | (0,-1) | (-0.707,0.707) |

#### `Basis25D.cs` — 基向量定义

`addons/node25d-cs/Basis25D.cs` 定义了 6 种视角模式的基向量常量（`FortyFive`、`Isometric`、`TopDown` 等），每个是包含 `x`、`y`、`z` 三个 `Vector2` 的结构体。

#### `Transform25D.cs` — 投影变换

`addons/node25d-cs/Transform25D.cs` 封装了投影变换矩阵，包含 `basis`（基向量）和 `spatialPosition`（3D 位置），`FlatPosition` 属性返回投影后的 2D 位置。

#### `YSort25D.cs` — Y 轴深度排序

`addons/node25d-cs/YSort25D.cs` 遍历父节点的所有 `Node2D` 子节点，按 Y 坐标排序并分配 `z_index`（从 -4000 开始，步长 2）。

#### `ShadowMath25D.cs` — 阴影投射

`addons/node25d-cs/ShadowMath25D.cs` 使用 `ShapeCast3D` 向下发射射线检测地面，将阴影定位到碰撞点。

#### `Gizmo25D.cs` — 编辑器拖拽手柄

`addons/node25d-cs/main_screen/Gizmo25D.cs` 在编辑器中显示 X/Y/Z 三轴拖拽线，支持鼠标拖拽移动 2.5D 对象。

### 4.2 游戏逻辑 (`assets/`)

#### `PlayerMath25D.cs` — 玩家 3D 物理

`assets/player/PlayerMath25D.cs` 继承 `CharacterBody3D`，处理 WASD 移动和跳跃。等距模式下将 WASD 映射到对角方向。

```csharp
// 等距操控：W→右上，S→左下，A→左上，D→右下
localX = new Vector3(0.70710678118f, 0, -0.70710678118f);
localZ = new Vector3(0.70710678118f, 0, 0.70710678118f);
```

#### `PlayerSprite.cs` — 玩家精灵动画

`assets/player/PlayerSprite.cs` 管理 8 方向动画（站立/跑步/跳跃），通过 `SetViewMode()` 在不同视角下压缩/倾斜精灵。

#### `CubeMath.cs` — 立方体旋转演示

`assets/cube/CubeMath.cs` 创建 27 个 `Node3D`（3×3×3 点阵），每帧读取 WASD/QE 输入旋转，将位置同步到 27 个 `CubePoint`。

---

## 5. 关键概念详解

### 5.1 投影矩阵

```
3D坐标(x,y,z) → x×basisX + y×basisY + z×basisZ → 2D位置
```

每个基向量定义了对应 3D 轴在 2D 屏幕上的方向和长度。

### 5.2 z_index 排序

Godot 的 `z_index` 范围 -4096~4096。项目从 -4000 开始，步长 2，留出 +1 给阴影层。

---

## 6. 场景树全景

```
DemoScene (Node2D)
├── Player25D (Node25D)
│   ├── PlayerMath25D (CharacterBody3D)
│   ├── PlayerSprite (Sprite2D)
│   └── Shadow25D (Node25D)
├── Platform0~23 (Node25D) ×24
└── YSort25D (Node)
```

---

## 7. 如何扩展

1. 创建 `Node25D` 作为根节点
2. 添加 3D 子节点用于物理，`Sprite2D` 子节点用于显示
3. 在 `Node25D.cs` 的 `SetViewMode()` 中添加新的视角模式
