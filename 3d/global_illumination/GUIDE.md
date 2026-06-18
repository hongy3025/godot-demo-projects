# 全局光照 (Global Illumination) - 源代码导读

> 本文档面向 Godot 新手，剖析全局光照演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名：**Global Illumination**（`project.godot` 中 `config/name`）

展示 Godot 的全局光照系统：LightmapGI、VoxelGI、SDFGI、ReflectionProbe，以及屏幕空间效果 SSAO 和 SSIL。

主场景：`test.tscn`

## 2. 快速上手

WASD 移动，鼠标环顾。**Space** 切换 GI 模式，**R** 切换反射探针模式，**F** 切换 SSIL 模式。Shift+按键反向切换。

## 3. 核心架构

```
test.tscn
├── Sun (DirectionalLight3D)
├── WorldEnvironment
├── Zdm2LightmapAll (Node3D)      ← 烘焙光照贴图的关卡
├── Zdm2LightmapIndirect (Node3D) ← 仅间接光照的关卡
├── LightmapGIAll / LightmapGIIndirect
├── VoxelGI
├── Camera (Node3D)
│   ├── ReflectiveSphere
│   │   └── ReflectionProbe
│   ├── Box
│   └── Decal
└── UI (Control)
```

## 4. 文件逐层导读

### `test.gd` — 主控脚本

**三个枚举定义 GI 模式：**
```gdscript
enum GIMode { NONE, LIGHTMAP_GI_ALL, LIGHTMAP_GI_INDIRECT, VOXEL_GI, SDFGI, MAX }
enum ReflectionProbeMode { NONE, ONCE, ALWAYS, MAX }
enum SSILMode { NONE, SSAO, SSIL, SSAO_AND_SSIL, MAX }
```

**关键方法：**

| 方法 | 作用 |
|------|------|
| `set_gi_mode()` | 切换 GI 模式，控制各 GI 节点显隐和光照烘焙模式 |
| `set_reflection_probe_mode()` | 切换反射探针模式（关闭/一次/始终更新） |
| `set_ssil_mode()` | 切换屏幕空间光照效果（SSAO/SSIL） |

### `camera.gd` — 摄像机控制

处理 WASD 移动和鼠标视角旋转。

## 5. 关键概念详解

### GI 模式对比

| 模式 | 性能 | 说明 |
|------|------|------|
| Environment Lighting | 最快 | 仅环境光照 |
| LightmapGI (All) | 快 | 烘焙直接+间接光照 |
| LightmapGI (Indirect) | 快 | 烘焙间接光照，动态物体受益 |
| VoxelGI | 慢 | 实时体素全局光照 |
| SDFGI | 慢 | 有符号距离场全局光照 |

### 动态物体适配

球体和盒子作为摄像机的子节点，展示动态物体在不同 GI 模式下的光照表现。Decal 节点为动态物体提供简单阴影，在 LightmapGI (All) 模式下特别有用。
