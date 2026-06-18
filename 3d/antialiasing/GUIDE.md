# 3D Anti-Aliasing - 源代码导读

> 本文档面向 Godot 新手，逐层剖析抗锯齿演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名：**3D Anti-Aliasing**（`project.godot` 中 `config/name`）

演示 Godot 支持的多种 3D 抗锯齿技术：MSAA、FXAA、SMAA、TAA、SSAA，以及 Alpha 抗锯齿和 FSR 1.0 升频。

主场景：`anti_aliasing.tscn`

## 2. 快速上手

运行后可通过 UI 面板切换不同抗锯齿模式，鼠标拖拽旋转视角，滚轮缩放。左右箭头键切换测试对象。

## 3. 核心架构

```
anti_aliasing.tscn
├── Testers (Node3D)          ← 多个测试对象子节点
├── CameraHolder (Node3D)     ← Y 轴旋转
│   └── RotationX (Node3D)    ← X 轴旋转
│       └── Camera3D          ← 摄像机
├── Antialiasing (Control)    ← UI 控制面板
└── FPSLabel / TestName 等    ← HUD
```

## 4. 文件逐层导读

### `anti_aliasing.gd` — 主控脚本

**关键常量：**
- `ROT_SPEED = 0.003` — 鼠标旋转速度
- `ZOOM_SPEED = 0.125` — 滚轮缩放速度

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化摄像机位置，检测 Compatibility 渲染器并隐藏不支持的选项 |
| `_unhandled_input()` | 处理鼠标旋转/缩放，左右切换测试对象 |
| `_process()` | 平滑移动摄像机到当前测试对象，更新 FPS 显示 |
| `_on_msaa_item_selected()` | 设置 MSAA 级别（`get_viewport().msaa_3d`） |
| `_on_taa_item_selected()` | 切换 TAA（`get_viewport().use_taa`） |
| `_on_screen_space_aa_item_selected()` | 设置 FXAA/SMAA（`get_viewport().screen_space_aa`） |
| `_on_render_scale_value_changed()` | 调整渲染缩放比例 |
| `_on_amd_fidelityfx_fsr1_toggled()` | 切换 FSR 1.0 升频模式 |

## 5. 关键概念详解

### 抗锯齿技术对比

| 技术 | 质量 | 性能 | 模糊 |
|------|------|------|------|
| MSAA | 高 | 慢 | 不模糊 |
| FXAA | 低 | 快 | 轻微模糊 |
| SMAA | 中 | 中 | 轻微模糊 |
| TAA | 高 | 快 | 轻微模糊 |
| SSAA | 最高 | 最慢 | 不模糊 |

### Compatibility 模式适配

在 `_ready()` 中检测 `RenderingServer.get_current_rendering_method()`，若为 `"gl_compatibility"`，则隐藏 TAA 和 SSAA 选项，并复制方向光以补偿 sRGB 混合。

### FSR 1.0

仅在渲染缩放 < 100% 时有效，通过 `Viewport.SCALING_3D_MODE_FSR` 启用。锐度值越低图像越锐利。
