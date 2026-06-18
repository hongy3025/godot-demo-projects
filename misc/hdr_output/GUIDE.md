# HDR 输出 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中实现高动态范围（HDR）输出"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.7** 的 HDR 输出演示项目。核心目标是：

> **展示如何在 Godot 中启用 HDR 输出、处理超出 SDR 范围的颜色值，以及动态调整 HDR 亮度参数。**

项目包含多个演示场景：
| 场景 | 说明 |
|------|------|
| **Color Sweep** | 颜色扫描，展示从暗到亮的 HDR 色域 |
| **Tone Map** | 色调映射，展示 HDR 颜色在 SDR 屏幕上的映射 |
| **Output Max Linear Value** | 3D 场景 + 颜色闪烁，展示最大线性值变化 |
| **In-Game HDR Settings** | 运行时调整 HDR 亮度和最大亮度 |

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

### 2.2 前提条件

- Windows 系统 + Direct3D 12 驱动（项目配置）
- 支持 HDR 的显示器
- Windows 中启用 HDR 显示

---

## 3. 核心架构

### 3.1 项目配置

```ini
[display]
window/hdr/request_hdr_output=true

[rendering]
rendering_device/driver.windows="d3d12"
viewport/hdr_2d=true
```

### 3.2 架构分层

```
┌──────────────────────────────────────┐
│          HDR 设置 UI 层              │
│  InGameHDRSettings (亮度/最大亮度)   │
├──────────────────────────────────────┤
│          颜色计算层                   │
│  max_color.gd / max_self_modulate.gd │
│  SDR→线性→HDR→SDR 颜色转换          │
├──────────────────────────────────────┤
│          演示场景层                   │
│  Color Sweep / Tone Map / 3D Scene   │
├──────────────────────────────────────┤
│         Godot HDR 输出层             │
│  Window.hdr_output_requested          │
│  DisplayServer HDR API               │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `max_color.gd` — 颜色最大线性值适配 ⭐

**地位：** 核心颜色计算工具，将 SDR 颜色映射到 HDR 色域。

**关键变量：**

| 变量 | 说明 |
|------|------|
| `sdr_color` | 输入的 SDR 颜色 |
| `linear_limit` | 最大线性值限制（-1.0 表示不限制） |
| `use_luminance_for_limit` | 是否使用亮度作为限制条件 |

**核心逻辑（`_on_output_max_linear_value_changed`）：**

```gdscript
var linear_color = sdr_color.srgb_to_linear()  # SDR → 线性空间
var max_rgb_value = maxf(linear_color.r, maxf(linear_color.g, linear_color.b))
linear_color *= output_max_linear_value / max_rgb_value  # 缩放到 HDR 范围
self.color = linear_color.linear_to_srgb()  # 线性 → SDR 编码
```

**流程：**
1. 将 SDR 颜色从 sRGB 编码转换为线性空间
2. 根据屏幕的最大线性值缩放颜色
3. 可选地应用亮度限制
4. 转换回 sRGB 编码用于显示

### 4.2 `max_self_modulate.gd` — CanvasItem 自调制适配

与 `max_color.gd` 逻辑相同，但作用于 `self_modulate` 属性（CanvasItem 的自调制颜色）。

### 4.3 `in_game_hdr_settings/in_game_hdr_settings.gd` — 运行时 HDR 设置 ⭐

**地位：** 允许玩家在游戏运行时调整 HDR 参数。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 从配置文件加载 HDR 设置 |
| `_process()` | 实时更新 HDR 状态显示 |
| `save_settings()` | 保存 HDR 设置到 `user://hdr_settings.cfg` |
| `erase_settings()` | 清除保存的 HDR 设置 |

**HDR 参数：**
- **参考亮度（Reference Luminance）：** 标准白点的亮度（nit）
- **最大亮度（Max Luminance）：** 屏幕能显示的最大亮度

### 4.4 `color_sweep/color_sweep.gd` — 颜色扫描

**功能：** 通过滑块控制扫描范围，在 HDR 色域中从暗到亮扫描。

**关键逻辑：**
```gdscript
sm.set_shader_parameter(&"max_value", window.get_output_max_linear_value())
```

将 HDR 最大线性值传递给着色器，着色器根据该值渲染颜色扫描。

### 4.5 `tonemap/sphere_and_light.gd` — 色调映射演示

**功能：** 一个旋转的 3D 球体，颜色在 HSV 色环上循环变化，展示 HDR 光照效果。

```gdscript
var new_color = Color.from_hsv(current_hue, 1.0, 1.0)
light.light_color = new_color
material.emission = new_color
```

### 4.6 `main/demo_scenes.gd` — 场景切换

**功能：** 通过选项卡切换不同的 HDR 演示场景。

```gdscript
func _on_demo_scene_item_selected(index: int) -> void:
    for i in range(scenes.size()):
        scenes[i].visible = i == index
```

---

## 5. 关键概念详解

### 5.1 SDR vs HDR

- **SDR（标准动态范围）：** 颜色值范围 0.0~1.0，对应 0~100 nit
- **HDR（高动态范围）：** 颜色值可以超过 1.0，对应更高的亮度（最高可达 10000 nit）

### 5.2 颜色编码转换

```
sRGB 编码（SDR）  →  srgb_to_linear()  →  线性空间
线性空间操作（缩放/限制）              →  计算
线性空间          →  linear_to_srgb()  →  sRGB 编码（显示）
```

### 5.3 最大线性值

`Window.get_output_max_linear_value()` 返回当前屏幕能显示的最大线性值。例如：
- SDR 屏幕：约 1.0（100 nit）
- HDR 屏幕：可能为 10.0（1000 nit）或更高

### 5.4 亮度限制

`linear_limit` 参数用于限制最终颜色的最大亮度，防止过亮：
- `use_luminance_for_limit = true`：基于亮度限制
- `use_luminance_for_limit = false`：基于颜色分量最大值限制

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Control)
├── DemoScenes (TabContainer)
│   ├── ColorSweep (Control)           ← 颜色扫描演示
│   ├── ToneMap (Control)              ← 色调映射演示
│   ├── OutputMaxLinearValue (Control) ← 3D 场景演示
│   └── SetupInstructions (Control)    ← 设置说明
├── InGameHDRSettings (Control)        ← HDR 设置面板
├── DebugInfo (Control)                ← 调试信息
└── DeveloperSettings (Control)        ← 开发者设置
```

---

## 7. 如何扩展

### 7.1 添加新的 HDR 演示场景

1. 创建新的场景和脚本
2. 在 `demo_scenes.gd` 的 `scenes` 数组中添加引用
3. 在 TabContainer 中添加对应的选项卡

### 7.2 自定义 HDR 颜色计算

继承 `max_color.gd` 或 `max_self_modulate.gd`，添加自定义的色调映射算法：

```gdscript
func custom_tone_map(linear_color: Color) -> Color:
    # 自定义色调映射曲线
    return linear_color / (linear_color + Color.ONE)
```

---

## 推荐阅读路径

1. **`max_color.gd`** — 理解 HDR 颜色计算的核心逻辑
2. **`in_game_hdr_settings.gd`** — 看运行时 HDR 参数调整
3. **`color_sweep.gd`** — 看 HDR 色域扫描的实现
4. **`sphere_and_light.gd`** — 看 HDR 光照效果
