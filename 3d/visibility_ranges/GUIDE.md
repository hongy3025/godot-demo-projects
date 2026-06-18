# 可见性范围 (HLOD) - 源代码导读

> 本文档面向 Godot 新手，剖析分层 LOD 演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Visibility Ranges (HLOD)**（`project.godot` 中 `config/name`）

展示如何使用可见性范围设置分层 LOD 系统，通过减少绘制调用和多边形数量提高性能。

主场景：`test.tscn`

## 2. 快速上手

WASD 移动，鼠标环顾。**L** 切换可见性范围，**F** 切换淡出模式（透明度/滞后）。

## 3. 核心架构

```
test.tscn
├── TreeClusters (Node3D)     ← 树集群
│   ├── Cluster_0
│   │   ├── Tree_0~15 (MeshInstance3D)  ← 16 棵单棵树
│   │   ├── ClusterHigh (MeshInstance3D) ← 高细节集群
│   │   └── ClusterLow (MeshInstance3D)  ← 低细节集群
│   └── ...
├── Camera3D
└── UI
```

## 4. 文件逐层导读

### `tree_clusters.gd` — 树集群管理

**四个 LOD 级别：**

| 级别 | 距离 | 内容 |
|------|------|------|
| LOD 0 | 0~20 单位 | 单棵树，高几何细节 |
| LOD 1 | 20~150 单位 | 单棵树，低几何细节 |
| LOD 2 | 150~450 单位 | 树集群，高几何细节 |
| LOD 3 | 450~1900 单位 | 树集群，低几何细节 |
| 隐藏 | >1900 单位 | 淡出消失 |

**可见性范围设置：** 通过 `GeometryInstance3D` 的 `visibility_range_begin` 和 `visibility_range_end` 属性控制。

### `camera.gd` — 摄像机控制

WASD 移动和鼠标视角旋转。

### `fps_label.gd` — FPS 显示

显示当前帧率，方便对比开启/关闭可见性范围的性能差异。

### 进一步优化

- 使用 `MultiMeshInstance3D` 减少绘制调用
- 远处使用冒名顶替精灵（Sprite3D 或 QuadMesh + 公告板）
