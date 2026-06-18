# 3D SubViewport Scaling - 源代码导读

> 本文档面向 Godot 新手，讲解如何独立缩放 3D 渲染分辨率而不影响 2D UI。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [操作说明](#4-操作说明)

---

## 1. 项目概述

演示如何通过 `Viewport.scaling_3d_scale` 和 `scaling_3d_mode` 独立控制 3D 渲染分辨率，2D UI（HUD）始终保持清晰。这对性能优化很有用——降低 3D 分辨率提升帧率，UI 不受影响。

---

## 2. 核心架构

```
主窗口 (Window)
├── 3D 渲染 (通过 scaling_3d_scale 缩放)
└── 2D UI (Control 节点，不受缩放影响)
```

**关键 API：**
- `get_tree().root.scaling_3d_scale` — 3D 缩放比例（1.0 = 100%）
- `get_tree().root.scaling_3d_mode` — 缩放模式（BILINEAR / FSR 等）

---

## 3. 文件逐层导读

### `hud.gd` — HUD 控制 ⭐

```gdscript
extends Control

var scale_factor: int = 1
var filter_mode := Viewport.SCALING_3D_MODE_BILINEAR

func _unhandled_input(input_event: InputEvent) -> void:
    if input_event.is_action_pressed(&"cycle_viewport_resolution"):
        scale_factor = wrapi(scale_factor + 1, 1, 5)
        viewport.scaling_3d_scale = 1.0 / scale_factor
        # 显示: "Scale: 100%" → "Scale: 50%" → "Scale: 33%" → "Scale: 25%"

    if input_event.is_action_pressed(&"toggle_filtering"):
        filter_mode = wrapi(filter_mode + 1, BILINEAR, MAX)
        viewport.scaling_3d_mode = filter_mode
```

**缩放模式：**

| 模式 | 说明 |
|------|------|
| `BILINEAR` | 双线性插值，平滑缩放 |
| `FSR` | AMD FidelityFX Super Resolution，锐化效果 |
| `FSR 2.2` | FSR 2.2 版本 |

---

## 4. 操作说明

| 按键 | 功能 |
|------|------|
| 空格 | 循环切换分辨率（100% → 50% → 33% → 25%） |
| Tab | 切换缩放过滤模式 |
