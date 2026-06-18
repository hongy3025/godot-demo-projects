# 可变速率着色 (VRS) - 源代码导读

> 本文档面向 Godot 新手，剖析可变速率着色演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Variable Rate Shading**（`project.godot` 中 `config/name`）

展示如何在 3D 中使用可变速率着色 (VRS) 提高性能，并显示性能指标。

主场景：`vrs.tscn`

## 2. 快速上手

运行后观察场景中的 VRS 效果和性能指标。通过 UI 调整 VRS 参数。

## 3. 核心架构

```
vrs.tscn
├── WorldEnvironment
├── DirectionalLight3D
├── Camera3D
├── 3D 场景物体
└── UI (Control)
```

## 4. 文件逐层导读

### `vrs.gd` — VRS 主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化 VRS 设置 |
| `_process()` | 更新性能指标显示 |

### `information.gd` — 信息显示

显示 VRS 状态和性能数据。

### VRS 配置

在 `project.godot` 中配置：
```ini
[rendering]
vrs/mode=1
vrs/texture="res://vrs_texture.png"
```

### VRS 原理

VRS 允许在不同屏幕区域使用不同的着色率：
- **中心区域：** 全着色率（高质量）
- **边缘区域：** 降低着色率（节省性能）

通过 VRS 纹理图控制各区域的着色率，在视觉质量影响最小的情况下提升性能。
