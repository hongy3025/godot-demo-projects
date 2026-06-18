# 2.5D Demo 项目源代码导读

> 本文档面向 GDScript 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中用 2D 精灵 + 3D 物理实现伪 3D 效果"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)
8. [附录：输入映射表](#8-附录输入映射表)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的 2.5D 技术演示项目。核心思路是：

> **用 3D 物理引擎做碰撞和位置计算，用 2D 精灵做渲染，通过投影矩阵将 3D 坐标映射到 2D 屏幕。**

这样做的好处：
- 直接使用 Godot 成熟的 3D 物理引擎（`CharacterBody3D`、`StaticBody3D`）
- 渲染层面保持 2D 的简单性和性能（`Sprite2D`、`Camera2D`）
- 支持 6 种视角模式一键切换（45 度、等距、俯视、正面、斜 Y、斜 Z）

项目包含两个可运行场景：
| 场景 | 路径 | 说明 |
|------|------|------|
| **主演示** | `assets/demo_scene.tscn` | 2.5D 平台关卡，可操控角色移动跳跃 |
| **立方体演示** | `assets/cube/cube.tscn` | 3x3x3 点阵立方体，展示 3D 旋转在 2.5D 下的效果 |

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `assets/demo_scene.tscn`。

### 2.2 操作键位

| 按键 | 功能 |
|------|------|
| WASD | 移动 |
| 空格 | 跳跃 |
| Shift | 慢走（减速） |
| R | 重置位置 |
| U / I / O / J / K / L | 切换 6 种视角模式 |
| T | 切换等距操控模式 |
| H | 显示/隐藏操作提示 |
| C | 切换到立方体演示 |
| Esc | 退出 |

---

## 3. 核心架构

### 3.1 核心公式

```
2D 屏幕位置 = 3D坐标.x × basisX + 3D坐标.y × basisY + 3D坐标.z × basisZ
```

其中 `basisX`、`basisY`、`basisZ` 是三个 `Vector2` 基向量，定义了从 3D 空间到 2D 屏幕的投影矩阵。

缩放因子 `SCALE = 32`，即 1 个 3D 单位 = 32 像素。

### 3.2 架构分层

```
┌──────────────────────────────────────────────────┐
│                   2D 渲染层                        │
│  Sprite2D / Camera2D / YSort25D / CanvasLayer    │
├──────────────────────────────────────────────────┤
│              2.5D 投影层 (Node25D)                │
│  3D 坐标 → 基向量投影 → 2D 全局坐标               │
├──────────────────────────────────────────────────┤
│                  3D 物理层                        │
│  CharacterBody3D / StaticBody3D / ShapeCast3D    │
│  物理碰撞、重力、移动计算                          │
└──────────────────────────────────────────────────┘
```

### 3.3 节点结构（以玩家为例）

```
Player25D (Node25D)              ← 2.5D 投影节点，管理 3D→2D 映射
├── PlayerMath25D (CharacterBody3D)  ← 3D 物理节点，处理移动/跳跃/重力
│   └── CollisionShape3D             ← 3D 碰撞体
├── PlayerSprite (Sprite2D)          ← 2D 精灵，显示角色外观和动画
└── Shadow25D (Node25D)              ← 阴影的 2.5D 投影节点
    ├── ShadowMath25D (ShapeCast3D)  ← 向下发射射线检测地面
    └── ShadowSprite (Sprite2D)      ← 阴影精灵
```

---

## 4. 文件逐层导读

### 4.1 核心插件层 (`addons/node25d/`)

这是整个 2.5D 系统的核心，作为一个 Godot 编辑器插件存在。

#### `node_25d.gd` — 核心投影节点 ⭐

**地位：** 整个项目的基石。所有 2.5D 对象都继承或使用此类。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `Node25D_ready()` | 初始化：获取第一个子节点作为 3D 节点，设置默认 45 度基向量 |
| `Node25D_process()` | 每帧执行 3D→2D 投影计算 |
| `set_view_mode(index)` | 切换 6 种视角模式，本质是修改三个基向量的值 |
| `get_basis()` | 返回当前基向量组，供 Gizmo 和排序使用 |

**6 种视角模式的基向量：**

| 模式 | basisX | basisY | basisZ | 视觉效果 |
|------|--------|--------|--------|----------|
| 0 - 45 度 | (1, 0) | (0, -0.707) | (0, 0.707) | 经典 45 度俯角 |
| 1 - 等距 | (0.866, 0.5) | (0, -1) | (-0.866, 0.5) | 2:1 像素比例 |
| 2 - 俯视 | (1, 0) | (0, 0) | (0, 1) | 纯俯视 |
| 3 - 正面 | (1, 0) | (0, -1) | (0, 0) | 纯正面 |
| 4 - 斜 Y | (1, 0) | (-0.707, -0.707) | (0, 1) | Y 轴倾斜 |
| 5 - 斜 Z | (1, 0) | (0, -1) | (-0.707, 0.707) | Z 轴倾斜 |

> **新手提示：** 基向量可以理解为"3D 坐标轴在 2D 屏幕上的投影方向"。比如 basisY = (0, -1) 表示"3D 的 Y 轴向上对应 2D 屏幕的向上方向"。

#### `y_sort_25d.gd` — Y 轴深度排序

**解决的问题：** 2D 渲染没有深度概念，远处的物体应该先画（z_index 更小），近处的后画（z_index 更大）。

**工作原理：**
1. 遍历父节点的所有 `Node2D` 子节点
2. 用 `Node25D.y_sort_slight_xz()` 按 Y 坐标排序（Y 相等时用 X+Z 微调）
3. 从 `z_index = -4000` 开始分配，每次 `+2`（留出 +1 给阴影层）

**限制：** 最多 4000 个节点（z_index 范围 -4096 ~ 4096）。

#### `shadow_math_25d.gd` — 阴影投射

**工作原理：**
1. 通过兄弟节点索引定位目标对象（阴影节点在场景树中紧跟在目标后面）
2. 每帧将 `ShapeCast3D` 定位到目标位置，向下发射球形射线
3. 检测到碰撞 → 将阴影定位到碰撞点（地面），显示阴影
4. 未检测到碰撞 → 隐藏阴影（悬空）

> **场景树要求：** 阴影节点必须是目标节点的下一个兄弟节点。

#### `node25d_plugin.gd` — 编辑器插件入口

**职责：**
- 注册三个自定义类型（`Node25D`、`YSort25D`、`ShadowMath25D`）
- 添加 "2.5D" 编辑器主屏幕面板
- 管理插件生命周期（启用/禁用）

#### `main_screen/viewport_25d.gd` — 编辑器 2.5D 视口

**功能：**
- 视角模式切换（通过按钮组）
- 鼠标滚轮缩放（指数级，13 级翻倍）
- 鼠标中键平移
- 选中 Node25D 时自动创建 Gizmo
- 递归更新编辑场景中所有节点的视角模式

#### `main_screen/gizmo_25d.gd` — 编辑器拖拽手柄

**功能：** 在 2.5D 视口中显示 X（红）/ Y（绿）/ Z（蓝）三轴拖拽线。

**关键逻辑：**
- 鼠标靠近轴线 20px 以内时高亮
- 拖拽时将 2D 鼠标位移投影到选中轴线的 2D 方向上
- 通过 `Node25D.SCALE` 换算回 3D 单位
- 拖拽结束后执行像素对齐（`_snap_spatial_position`）

---

### 4.2 游戏逻辑层 (`assets/`)

#### `player/player_math_25d.gd` — 玩家 3D 物理

**继承自 `CharacterBody3D`**，处理：
- **水平移动：** WASD 输入 → `move_and_slide()`，速度 10，Shift 减半
- **垂直移动：** 跳跃速度 60，重力 240，`move_and_collide()` 检测落地
- **等距操控模式（T 键切换）：** 在等距视角下将 WASD 映射到对角方向

**等距操控的原理：**
- 普通模式：W=前(Z-)、S=后(Z+)、A=左(X-)、D=右(X+)
- 等距模式：W=右上、S=左下、A=左上、D=右下（与视觉方向一致）

#### `player/player_sprite.gd` — 玩家精灵动画

**8 方向动画系统：**

| 方向索引 | 朝向 | 说明 |
|---------|------|------|
| 0 | 下 | 面向屏幕下方 |
| 1 | 左下 | 面向左下方 |
| 2 | 左/右 | 通过 `flip_h` 镜像 |
| 3 | 左上 | 面向左上方 |
| 4 | 上 | 面向屏幕上方 |

**三种动画状态：**
- **站立：** 单帧纹理，8 方向各一帧
- **跑步：** 6 帧循环纹理，每方向 6 帧（hframes=6）
- **跳跃：** 2 帧纹理，区分上升/下落

**视角适配：** 通过修改 Sprite 的 `transform` 在不同视角下压缩/倾斜精灵，使其看起来"贴合"地面。

#### `platform/platform_sprite.gd` — 平台精灵

为 6 种视角模式预加载了不同的平台贴图。视角切换时直接更换 `texture`。

#### `shadow/shadow_sprite.gd` — 阴影精灵

与平台精灵同理，为 6 种视角模式预加载不同的阴影贴图。

#### `cube/cube_math.gd` — 立方体旋转演示

**逻辑：**
1. `_ready()` 中创建 27 个 `Node3D`（3×3×3 点阵，间距 5 单位）
2. 首次 `_process()` 时实例化 27 个 `CubePoint`（每个是一个 `Node25D`）添加到父节点
3. 之后每帧读取 WASD/QE 输入旋转本节点
4. 将旋转后的 3D 位置同步到每个 `CubePoint` 的 3D 子节点

**为什么不在 `_ready()` 中创建 CubePoint？** 因为此时父节点（场景根）尚未完全就绪，直接添加子节点可能导致状态不一致。

#### `ui/control_hints.gd` — 控制提示显隐

最简单的脚本：按 H 键切换 `visible` 属性。

---

## 5. 关键概念详解

### 5.1 什么是 2.5D？

2.5D 是介于 2D 和 3D 之间的视觉风格。常见实现方式：
- **3D 模型 + 固定视角**（如暗黑破坏神 2）
- **2D 精灵 + 3D 物理**（本项目采用的方式）
- **3D 场景 + 正交相机**

### 5.2 投影矩阵的工作方式

```
3D 坐标 (x, y, z)
       ↓
   x × basisX  →  2D 向量
 + y × basisY  →  2D 向量
 + z × basisZ  →  2D 向量
       ↓
  2D 位置 (最终结果)
```

每个基向量定义了对应 3D 轴在 2D 屏幕上的"方向和长度"。

### 5.3 z_index 排序策略

Godot 的 `z_index` 范围是 -4096 ~ 4096。项目使用：
- 从 -4000 开始，每次 +2
- 留出 +1 给阴影层（阴影的 z_index 可以在物体和地面之间）
- 最大支持 4000 个排序节点

### 5.4 等距操控模式

在等距视角下，如果直接使用 WASD，玩家会感觉"方向不对"（因为等距投影中 X 和 Z 轴在屏幕上是对角方向）。

**解决方案：**
- **等距模式（T 键切换）：** 将 WASD 映射到对角方向
  - W → 右上（X+, Z-）
  - S → 左下（X-, Z+）
  - A → 左上（X-, Z-）
  - D → 右下（X+, Z+）

### 5.5 阴影系统的工作流程

```
每帧物理更新:
  1. ShadowMath25D.position = 目标对象.position
  2. 发射 ShapeCast3D 向下检测
  3. 有碰撞 → 阴影定位到碰撞点，显示
  4. 无碰撞 → 隐藏阴影
```

阴影的 z_index 比物体大 1（在 YSort25D 排序时步长为 2，阴影在中间）。

---

## 6. 场景树全景

### 6.1 主场景 `demo_scene.tscn`

```
DemoScene (Node2D)
├── Overlay (CanvasLayer)            ← HUD 层
│   └── ControlHints (Control)       ← 操作提示文本
│
├── Player25D (Node25D)              ← 玩家（2.5D 投影）
│   ├── PlayerMath25D (CharacterBody3D)  ← 3D 物理
│   │   └── CollisionShape3D
│   ├── PlayerSprite (Sprite2D)      ← 2D 精灵
│   │   └── PlayerCamera (Camera2D)  ← 2D 相机
│   └── Shadow25D (Node25D)          ← 阴影
│       ├── ShadowMath25D (ShapeCast3D)
│       └── ShadowSprite (Sprite2D)
│
├── Platform0~23 (Node25D) ×24       ← 24 个平台
│   ├── PlatformMath (StaticBody3D)
│   │   └── CollisionShape3D
│   └── PlatformSprite (Sprite2D)
│
├── YSort25D (Node)                  ← 深度排序
└── AudioStreamPlayer                ← 背景音乐
```

### 6.2 立方体场景 `cube.tscn`

```
Cube (Node2D)
├── CubeMath (Node3D)                ← 3D 旋转逻辑
│   ├── CubeMath #0~26 (Node3D) ×27 ← 27 个 3D 标记点
│   └── ...
├── CubePoint #0~26 (Node25D) ×27   ← 27 个 2.5D 投影点
│   └── Node3D                       ← 3D 位置（由 CubeMath 同步）
└── OverlayCube (CanvasLayer)        ← HUD
```

---

## 7. 如何扩展

### 7.1 添加新的 2.5D 对象

1. 创建一个 `Node25D` 作为根节点
2. 添加一个 3D 子节点（`CharacterBody3D` 或 `StaticBody3D`）用于物理
3. 添加一个 `Sprite2D` 子节点用于显示
4. （可选）添加 `Shadow25D` 子节点用于阴影

### 7.2 添加新的视角模式

在 `node_25d.gd` 的 `set_view_mode()` 中添加新的 `match` 分支：

```gdscript
6:  # 自定义视角
    _basisX = SCALE * Vector2(1, 0)
    _basisY = SCALE * Vector2(0, -0.5)
    _basisZ = SCALE * Vector2(0, 0.5)
```

同时需要在 `project.godot` 中添加对应的输入映射，并在各个 Sprite 脚本中添加对应的贴图。

### 7.3 移除视角切换（固定视角）

如果游戏只需要一种视角：
1. 删除 `_check_view_mode()` 方法
2. 删除所有 Sprite 脚本中的视角切换逻辑
3. 每个精灵只需一张贴图

### 7.4 使用自己的精灵

- 精灵贴图需要为每种视角模式准备对应的渲染图
- 玩家精灵需要 8 方向 × 3 状态（站立/跑步/跳跃）的帧布局
- 参考 `assets/player/textures/` 下的贴图布局

---

## 8. 附录：输入映射表

| 动作名 | 按键 | 用途 |
|--------|------|------|
| `move_right` | D / 右方向键 | 向右移动 |
| `move_left` | A / 左方向键 | 向左移动 |
| `move_forward` | W / 上方向键 | 向前移动 |
| `move_back` | S / 下方向键 | 向后移动 |
| `movement_modifier` | Shift | 减速 |
| `jump` | 空格 | 跳跃 |
| `reset_position` | R | 重置位置 |
| `forty_five_mode` | U | 45 度视角 |
| `isometric_mode` | I | 等距视角 |
| `top_down_mode` | O | 俯视视角 |
| `front_side_mode` | J | 正面视角 |
| `oblique_y_mode` | K | 斜 Y 视角 |
| `oblique_z_mode` | L | 斜 Z 视角 |
| `toggle_isometric_controls` | T | 切换等距操控 |
| `toggle_control_hints` | H | 切换提示显隐 |
| `move_clockwise` | E | 顺时针旋转（立方体） |
| `move_counterclockwise` | Q | 逆时针旋转（立方体） |
| `view_cube_demo` | C | 切换演示场景 |
| `exit` | Esc | 退出游戏 |

---

## 推荐阅读路径

如果你是 GDScript 新手，建议按以下顺序阅读源码：

1. **`node_25d.gd`** — 理解 2.5D 的核心投影原理
2. **`player_math_25d.gd`** — 看 3D 物理如何与 2.5D 配合
3. **`player_sprite.gd`** — 看 2D 精灵如何响应 3D 状态
4. **`y_sort_25d.gd`** — 理解深度排序的必要性
5. **`shadow_math_25d.gd`** — 看阴影系统的实现
6. **`cube_math.gd`** — 看 3D 旋转在 2.5D 下的效果
7. **`viewport_25d.gd`** + **`gizmo_25d.gd`** — 编辑器工具（进阶）
