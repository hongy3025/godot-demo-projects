# 遮挡剔除和网格 LOD - 源代码导读

> 本文档面向 Godot 新手，剖析遮挡剔除和 LOD 演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Occlusion Culling and Mesh LOD**（`project.godot` 中 `config/name`）

展示在 3D 场景中使用遮挡剔除和网格 LOD（细节级别）。包含 1,024 个相同房间（64×64 网格）。

主场景：`node_3d.tscn`

## 2. 快速上手

WASD 移动，鼠标环顾。**O** 切换遮挡剔除，**L** 切换网格 LOD，**Space** 切换绘制模式，**F** 切换门开关，**V** 切换 V-Sync。

## 3. 核心架构

```
node_3d.tscn
├── Rooms (Node3D)            ← 1024 个房间
│   ├── Room_0_0
│   │   ├── MeshInstance3D
│   │   ├── OccluderInstance3D
│   │   └── Door (StaticBody3D)
│   └── ...
├── Spheres (Node3D)          ← 蓝色 LOD 球体
├── Camera3D
└── UI (Control)
```

## 4. 文件逐层导读

### `node_3d.gd` — 场景主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化场景，禁用 V-Sync |
| `_input()` | 处理 O/L/Space/F/V 等快捷键 |
| `_process()` | 更新 FPS 显示 |

**遮挡剔除切换：**
```gdscript
get_viewport().use_occlusion_culling = button_pressed
```

**网格 LOD 切换：**
```gdscript
get_viewport().mesh_lod_threshold = 0.0 if disabled else 1.0
```

### `camera.gd` — 摄像机控制

处理 WASD 移动和鼠标视角旋转。

### `door.gd` — 门开关

按 F 键切换门的开/关状态，演示动态物体对遮挡剔除的影响。

### 性能优化原理

| 技术 | 作用 | 适用场景 |
|------|------|---------|
| 遮挡剔除 | 被墙壁遮挡的房间不渲染 | 室内场景 |
| 网格 LOD | 远处物体使用低多边形模型 | 大多数场景 |

> 蓝色球体使用自动生成的 LOD，减少 GPU 每帧需要渲染的三角形数量。
