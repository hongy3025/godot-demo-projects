# 材质测试器 - 源代码导读

> 本文档面向 Godot 新手，剖析材质测试演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Material Testers**（`project.godot` 中 `config/name`）

包含许多具有复杂材质的球状物体，用于展示 Godot 的渲染能力。曾在 Godot 3.0 预告片开头出现。

主场景：`material_tester.tscn`

## 2. 快速上手

左右箭头键切换不同的材质测试示例。鼠标拖拽旋转视角，滚轮缩放。

## 3. 核心架构

```
material_tester.tscn
├── Testers (Node3D)          ← 多个材质测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
├── DirectionalLight3D
└── UI (Control)
```

## 4. 文件逐层导读

### `tester.gd` — 主控脚本

与抗锯齿演示相同的测试浏览模式。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化摄像机，检测 Compatibility 渲染器 |
| `_unhandled_input()` | 鼠标旋转/缩放，切换测试对象 |
| `_process()` | 平滑移动摄像机到当前测试对象 |

### 材质类型展示

场景中的 `Testers` 节点下包含多种材质示例：

| 材质类型 | 说明 |
|---------|------|
| StandardMaterial3D | 标准 PBR 材质 |
| ORM 材质 |  occlusion/roughness/metallic 贴图 |
| 各向异性材质 | 拉丝金属效果 |
| 透明材质 | 玻璃、水面效果 |
| 自发光材质 | 发光效果 |
| 清漆材质 | 清漆涂层效果 |
|  subsurface 材质 | 次表面散射效果 |

### 渲染设置

`project.godot` 中配置了 MSAA 2×、各向异性过滤 4×、去条带等高质量渲染设置。
