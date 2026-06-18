# 导航网格区块 3D - 源代码导读

> 本文档面向 Godot 新手，剖析导航网格区块演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Navigation Mesh Chunks 3D**（`project.godot` 中 `config/name`）

演示如何为大型世界区块系统烘焙导航网格。

主场景：`navmesh_chhunks_demo_3d.tscn`

## 2. 快速上手

鼠标左键点击更改调试路径的起始位置。观察角色在不同区块间的导航路径。

## 3. 核心架构

```
navmesh_chhunks_demo_3d.tscn
├── NavigationRegion3D × N   ← 多个导航网格区块
├── Character (CharacterBody3D)
├── NavigationAgent3D
└── Camera3D
```

## 4. 文件逐层导读

### `navmesh_chhunks_demo_3d.gd` — 主控脚本

**核心概念：** 将大型世界分割为多个 `NavigationRegion3D` 区块，每个区块独立烘焙导航网格。

**关键逻辑：**
1. 区块管理：动态加载/卸载导航网格区块
2. 跨区块寻路：`NavigationServer3D` 自动处理区块间的路径连接
3. 调试路径：鼠标点击设置起点，显示到目标位置的导航路径

### 区块系统工作原理

```
区块 A (NavigationRegion3D) ─── 区块 B (NavigationRegion3D)
        │                              │
        └────────── 连接边 ────────────┘
                NavigationServer3D 自动合并
```

每个区块的导航网格独立烘焙，`NavigationServer3D` 在运行时自动连接相邻区块的边界，实现跨区块无缝寻路。

### 渲染器

使用 Compatibility 渲染器（`gl_compatibility`），兼容更广泛的硬件。
