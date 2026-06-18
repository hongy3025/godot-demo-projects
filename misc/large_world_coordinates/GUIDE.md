# 大世界坐标 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"Godot 的双精度渲染和物理支持"。

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

这是一个 **Godot 4.6** 的大世界坐标演示项目。核心目的是：

> **展示单精度与双精度构建在远距离坐标下的精度差异，帮助开发者理解何时需要双精度支持。**

- **单精度构建：** 距离原点几千单位后出现精度误差（抖动）
- **双精度构建：** 即使距离原点数十亿单位，网格仍然稳定

> **注意：** 官方 Godot 构建默认不启用双精度，需要编译自定义引擎。

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `test.tscn`。

### 2.2 操作说明

| 操作 | 功能 |
|------|------|
| 鼠标拖拽 | 旋转视角 |
| 滚轮 | 缩放 |
| Increment X/Y/Z 按钮 | 沿各轴移动物体（按住持续移动） |
| Go To 按钮 | 跳转到指定 X 坐标（0/10000/100000/1000000） |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│           UI 控制层                   │
│  坐标显示 / 移动按钮 / 跳转按钮      │
├──────────────────────────────────────┤
│           3D 场景层                   │
│  Camera3D / 移动物体 / RigidBody3D   │
├──────────────────────────────────────┤
│         Godot 坐标系统                │
│  单精度 (float) / 双精度 (double)    │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `controls.gd` — 控制脚本 ⭐

**地位：** 项目的核心，处理所有用户交互和坐标更新。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `ROT_SPEED` | 0.003 | 视角旋转速度 |
| `ZOOM_SPEED` | 0.5 | 缩放速度 |
| `MAIN_BUTTONS` | 左/中/右键掩码 | 拖拽旋转的鼠标按键 |

**关键变量：**

| 变量 | 说明 |
|------|------|
| `camera` | 摄像机节点 |
| `camera_holder` | 摄像机水平旋转父节点 |
| `rotation_x` | 摄像机垂直旋转父节点 |
| `node_to_move` | 被移动的 3D 物体 |
| `rigid_body` | 物理刚体 |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 检测是否为双精度构建，更新提示文字 |
| `_process(delta)` | 持续移动物体并更新坐标显示 |
| `_input(event)` | 处理鼠标旋转和缩放 |

**双精度检测：**

```gdscript
if OS.has_feature("double"):
    %HelpLabel.text = "Double precision is enabled..."
```

**坐标移动逻辑：**

```gdscript
if %IncrementX.button_pressed:
    node_to_move.position.x += 10_000 * delta
if %IncrementY.button_pressed:
    node_to_move.position.y += 100_000 * delta
if %IncrementZ.button_pressed:
    node_to_move.position.z += 1_000_000 * delta
```

各轴移动速度不同（X: 1万/秒, Y: 10万/秒, Z: 100万/秒），方便观察不同距离下的精度表现。

**视角控制：**

```gdscript
# 旋转
rot_y -= relative_motion.x * ROT_SPEED
rot_x -= relative_motion.y * ROT_SPEED
rot_x = clampf(rot_x, -1.4, 0.16)

# 缩放
zoom = clampf(zoom, 4, 15)
camera.position.z = zoom
```

**跳转坐标：**

```gdscript
func _on_go_to_button_pressed(x_position: int) -> void:
    if x_position == 0:
        node_to_move.position = Vector3.ZERO  # 重置所有坐标
    else:
        node_to_move.position.x = x_position
```

预设跳转位置：0、10000、100000、1000000。

---

## 5. 关键概念详解

### 5.1 单精度 vs 双精度

| 特性 | 单精度 (float) | 双精度 (double) |
|------|----------------|-----------------|
| 字节数 | 4 字节 | 8 字节 |
| 有效位数 | ~7 位 | ~15 位 |
| 远距离精度 | 几千单位后抖动 | 数十亿单位仍稳定 |
| 性能 | 较快 | 较慢 |
| 官方构建 | 默认 | 需编译 |

### 5.2 精度误差的表现

当物体距离原点很远时，单精度浮点数无法精确表示小数部分，导致：
- 网格抖动
- 物体位置跳跃
- 物理碰撞不稳定

### 5.3 物理设置

项目将物理更新率设为 120 FPS：
```ini
[physics]
common/physics_ticks_per_second=120
```

---

## 6. 场景树全景

### 6.1 主场景 `test.tscn`

```
Test (Node3D)
├── CameraHolder (Node3D)              ← 水平旋转
│   └── RotationX (Node3D)             ← 垂直旋转
│       └── Camera3D                   ← 摄像机
├── NodeToMove (Node3D)                ← 被移动的物体
│   └── MeshInstance3D                 ← 可见网格
├── RigidBody3D                        ← 物理刚体
├── WorldEnvironment                   ← 环境设置
├── DirectionalLight3D                 ← 方向光
└── Controls (VBoxContainer)           ← UI 控制面板
    ├── Coordinates (RichTextLabel)    ← 坐标显示
    ├── HelpLabel (Label)              ← 精度提示
    ├── Increment X/Y/Z (Button)
    ├── Go To 0/10000/100000/1000000 (Button)
    └── OpenDocumentation (Button)
```

---

## 7. 如何扩展

### 7.1 添加更多测试坐标

在 `_on_go_to_button_pressed` 中添加更多跳转位置：

```gdscript
const JUMP_POSITIONS = [0, 10000, 100000, 1000000, 10000000]
```

### 7.2 测试不同物体类型

添加更多 `NodeToMove` 类型的节点，如 `CharacterBody3D`、`RigidBody3D`，观察不同类型在远距离下的表现差异。

---

## 推荐阅读路径

1. **`controls.gd`** — 理解坐标移动和视角控制的核心逻辑
2. **`project.godot`** — 查看物理和渲染设置
