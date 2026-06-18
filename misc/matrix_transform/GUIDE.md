# 矩阵变换 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"Godot 中的变换（Transform）工作原理"。

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

这是一个 **Godot 4.6** 的矩阵变换可视化项目。**此项目不用于运行，仅在编辑器中使用。**

> **通过操作 AxisMarker 对象，直观地观察平移、旋转、缩放和剪切如何影响变换的基向量和原点向量。**

项目包含两个场景：
| 场景 | 说明 |
|------|------|
| `2D.tscn` | 2D 变换可视化 |
| `3D.tscn` | 3D 变换可视化 |

---

## 2. 快速上手

### 2.1 使用方式

在 Godot 编辑器中打开 `project.godot`，不要运行项目。直接在编辑器中：
1. 打开 `2D.tscn` 或 `3D.tscn`
2. 选中场景中的 `AxisMarker` 对象
3. 在视口中拖拽或检查器中修改变换属性
4. 观察彩色线条的变化

### 2.2 颜色约定

| 维度 | X 轴 | Y 轴 | Z 轴 | 原点 |
|------|------|------|------|------|
| 2D | 红色 | 绿色 | - | 蓝色 |
| 3D | 红色 | 绿色 | 蓝色 | 青色 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          可视化显示层                 │
│  Line2D / MeshInstance3D (彩色线条)  │
├──────────────────────────────────────┤
│          变换标记层                   │
│  AxisMarker2D / AxisMarker3D         │
│  继承 Node2D / Node3D，@tool 脚本    │
├──────────────────────────────────────┤
│          场景对象层                   │
│  用户可操作的 AxisMarker 实例        │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `marker/AxisMarker2D.gd` — 2D 轴标记 ⭐

**地位：** 2D 变换可视化的核心，继承 `Node2D`，标记为 `@tool` 脚本。

```gdscript
@tool
@icon("res://marker/AxisMarker2D.svg")
class_name AxisMarker2D
extends Node2D
```

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_process()` | 每帧更新原点向量的位置 |

**核心逻辑：**

```gdscript
func _process(_delta: float) -> void:
    var line: Line2D = get_child(0).get_child(0)
    var marker_parent: Node = get_parent()
    line.points[1] = transform.origin
    if marker_parent as Node2D != null:
        line.transform = marker_parent.global_transform
```

- `line.points[1]` 设置为当前节点的 `transform.origin`（从原点指向当前位置的向量）
- `line.transform` 设置为父节点的全局变换（避免抖动）

### 4.2 `marker/AxisMarker3D.gd` — 3D 轴标记 ⭐

**地位：** 3D 变换可视化的核心，继承 `Node3D`，标记为 `@tool` 脚本。

```gdscript
@tool
@icon("res://marker/AxisMarker3D.svg")
class_name AxisMarker3D
extends Node3D
```

**核心逻辑：**

```gdscript
func _process(_delta: float) -> void:
    var holder: Node3D = get_child(0).get_child(0)
    var cube: Node3D = holder.get_child(0)
    if position == Vector3():
        holder.transform = Transform3D()
        cube.transform = Transform3D().scaled(Vector3.ONE * 0.0001)
        return
    holder.transform = Transform3D(Basis(), position / 2)
    holder.transform = holder.transform.looking_at(position, Vector3.UP)
    holder.transform = get_parent().global_transform * holder.transform
    cube.transform = Transform3D(Basis().scaled(Vector3(0.1, 0.1, position.length())))
```

**逻辑说明：**
1. 如果位置为原点，隐藏原点向量（缩放到极小）
2. 否则，计算从原点到当前位置的向量
3. `holder` 定位到中点，朝向目标位置
4. `cube` 拉伸成长方体，长度等于距离

---

## 5. 关键概念详解

### 5.1 变换的组成

Godot 中的变换由三部分组成：
- **原点（Origin）：** 位置
- **基向量（Basis）：** 旋转 + 缩放 + 剪切
- **子节点继承：** 子节点继承父节点的变换

### 5.2 避免抖动

**问题：** 如果原点向量直接作为子节点，当父节点变换变化时，子节点位置会"抖动"。

**解决方案：** 原点向量是父节点的子节点，继承父节点的变换。这样原点向量始终指向正确位置，不会因父节点变换而产生双重偏移。

### 5.3 @tool 脚本

`@tool` 关键字使脚本在编辑器中运行，这是项目能在编辑器中实时更新可视化效果的关键。

---

## 6. 场景树全景

### 6.1 2D 场景 `2D.tscn`

```
2D (Node2D)
├── AxisMarker (AxisMarker2D)          ← 可操作的标记
│   └── Origin (Node2D)                ← 原点向量父节点
│       └── Line2D                     ← 从原点到标记的连线
└── ... (更多 AxisMarker 实例)
```

### 6.2 3D 场景 `3D.tscn`

```
3D (Node3D)
├── AxisMarker (AxisMarker3D)          ← 可操作的标记
│   └── Origin (Node3D)                ← 原点向量父节点
│       └── Holder (Node3D)            ← 中点定位
│           └── Cube (MeshInstance3D)  ← 从原点到标记的长方体
├── Camera3D
└── ... (更多 AxisMarker 实例)
```

---

## 7. 如何扩展

### 7.1 添加更多 AxisMarker

在场景中复制现有的 AxisMarker 节点，修改其变换属性，观察子节点的变换继承效果。

### 7.2 自定义可视化样式

修改 `AxisMarker2D.gd` 或 `AxisMarker3D.gd` 中的颜色、线条宽度或网格形状：

```gdscript
# 修改 2D 线条颜色
line.default_color = Color.RED
```

### 7.3 添加剪切可视化

在 AxisMarker 中添加额外的视觉元素来显示剪切变换的效果。

---

## 推荐阅读路径

1. **`marker/AxisMarker2D.gd`** — 理解 2D 变换可视化
2. **`marker/AxisMarker3D.gd`** — 理解 3D 变换可视化
3. **`2D.tscn` / `3D.tscn`** — 在编辑器中操作查看效果
