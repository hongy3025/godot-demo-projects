# OpenXR Passthrough - 源代码导读

> 本文档面向 Godot 新手，讲解如何在 VR 头显中启用透视（Passthrough）功能。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 OpenXR 透视功能，使用头显摄像头将真实世界显示在 VR 头显中。支持 AR（透视）和 VR（不透明）模式切换，以及"挖洞"着色器效果。

---

## 2. 核心架构

```
start_vr.gd → 初始化 OpenXR
    ↓
main.gd → 切换 AR/VR 模式
    ├── switch_to_ar() → 启用透视
    └── switch_to_vr() → 关闭透视
    ↓
fade_message.gd → 显示提示信息（自动淡出）
```

---

## 3. 文件逐层导读

### `main.gd` — AR/VR 模式切换 ⭐

```gdscript
func switch_to_ar() -> bool:
    var modes = xr_interface.get_supported_environment_blend_modes()
    if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
        xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
    elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
        xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE

    viewport.transparent_bg = true           # 关键：透明背景
    environment.background_mode = BG_COLOR
    environment.background_color = Color(0, 0, 0, 0)  # 全透明
```

**切换 AR 的关键步骤：**
1. 设置 `environment_blend_mode` 为 `ALPHA_BLEND` 或 `ADDITIVE`
2. 启用 `viewport.transparent_bg = true`
3. 设置环境背景为透明

**切换 VR：**

```gdscript
func switch_to_vr() -> bool:
    xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
    viewport.transparent_bg = false
    environment.background_mode = BG_SKY
```

**按钮切换：** A/X 按钮在 AR/VR 之间切换。

### `fade_message.gd` — 淡出消息

```gdscript
class_name FadeMessage3D
extends Node3D

# 显示文本 → 延迟 fade_delay 秒 → fade_duration 秒内淡出
```

### `holepunch.gdshader` — 挖洞着色器

将指定区域的渲染结果替换为透视画面，用于在虚拟物体上"挖洞"看到真实世界。

---

## 4. 关键概念详解

### 环境混合模式

| 模式 | 说明 | 用途 |
|------|------|------|
| `OPAQUE` | 不透明 | 纯 VR |
| `ALPHA_BLEND` | Alpha 混合 | 透视（推荐） |
| `ADDITIVE` | 叠加 | 透视（备选） |

### 透视工作流程

```
1. 设置 environment_blend_mode → ALPHA_BLEND
2. 启用 viewport.transparent_bg → true
3. 设置环境背景为透明黑色
4. 头显摄像头画面作为背景显示
5. 3D 物体叠加在真实世界上
```
