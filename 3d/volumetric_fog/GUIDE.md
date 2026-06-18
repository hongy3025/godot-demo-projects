# 体积雾 - 源代码导读

> 本文档面向 Godot 新手，剖析体积雾演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Volumetric Fog**（`project.godot` 中 `config/name`）

Godot 使用 Vulkan 渲染器的体积雾功能示例。

主场景：`volumetric_fog.tscn`

## 2. 快速上手

WASD 移动，鼠标环顾。**Space** 切换时间重投影，**左/右箭头** 调整雾密度，**上/下箭头** 调整时间重投影强度，**Page Up/Down** 调整体积雾质量。

## 3. 核心架构

```
volumetric_fog.tscn
├── WorldEnvironment
│   └── Environment (volumetric_fog_enabled)
├── DirectionalLight3D
├── FogVolume × N            ← 多个雾体积
├── Camera3D
└── UI
```

## 4. 文件逐层导读

### `camera.gd` — 摄像机控制

处理 WASD 移动和鼠标视角旋转，以及体积雾参数调整。

### 体积雾功能

| 功能 | 说明 |
|------|------|
| 正/负密度体积 | 影响反照率和发射 |
| 盒体/椭球体形状 | 不同形状的雾体积 |
| 高度衰减 | 随高度变化密度 |
| 3D 纹理密度调制 | 使用 3D 纹理控制密度 |
| 时间重投影 | 提高稳定性，避免闪烁 |

### FogVolume 节点

| 属性 | 说明 |
|------|------|
| `shape` | 盒体或椭球体 |
| `size` | 体积大小 |
| `material` | FogVolume 材质（密度、颜色等） |

### 自定义着色器

包含实时 3D 噪声的自定义 FogVolume 着色器，来自 [alghost](https://godotshaders.com/shader/moving-gradient-noise-fog-mist-for-godot-4/)。
