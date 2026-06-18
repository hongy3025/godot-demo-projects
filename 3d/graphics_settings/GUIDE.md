# 3D 图形设置 - 源代码导读

> 本文档面向 Godot 新手，剖析图形设置演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Graphics Settings**（`project.godot` 中 `config/name`）

展示一个完整的图形设置菜单示例，涵盖视频设置和效果设置。

主场景：`control.tscn`

## 2. 快速上手

运行后通过 UI 面板调整各种图形设置，实时观察 3D 场景的变化。点击"Hide settings"可隐藏面板以便观察。

## 3. 核心架构

```
control.tscn
├── WorldEnvironment          ← 环境效果（SSAO、SSR、辉光等）
├── Node3D
│   ├── DirectionalLight3D
│   ├── Camera3D
│   ├── OmniLight3D
│   └── SpotLight3D
└── SettingsMenu (Control)    ← 设置 UI 面板
```

## 4. 文件逐层导读

### `settings.gd` — 设置主控脚本

继承自 `Control`，处理所有图形设置的 UI 交互。

**视频设置方法：**

| 方法 | 作用 |
|------|------|
| `_on_ui_scale_option_button_item_selected()` | UI 缩放（66%~200%） |
| `_on_quality_slider_value_changed()` | 渲染缩放比例 |
| `_on_filter_option_button_item_selected()` | 显示滤镜（Bilinear/FSR 1.0/FSR 2.2） |
| `_on_vsync_option_button_item_selected()` | 垂直同步（禁用/自适应/启用） |
| `_on_msaa_option_button_item_selected()` | MSAA 抗锯齿级别 |
| `_on_taa_option_button_item_selected()` | TAA 开关 |
| `_on_screen_space_aa_option_button_item_selected()` | FXAA/SMAA |
| `_on_fullscreen_option_button_item_selected()` | 全屏模式 |
| `_on_fov_slider_value_changed()` | 摄像机视野 |

**效果设置方法：**

| 方法 | 作用 |
|------|------|
| `_on_ss_reflections_option_button_item_selected()` | 屏幕空间反射 |
| `_on_ssao_option_button_item_selected()` | 屏幕空间环境光遮蔽 |
| `_on_ssil_option_button_item_selected()` | 屏幕空间间接光照 |
| `_on_sdfgi_option_button_item_selected()` | SDFGI 全局光照 |
| `_on_glow_option_button_item_selected()` | 辉光效果 |
| `_on_volumetric_fog_option_button_item_selected()` | 体积雾 |

**预设系统：** `_on_very_low_preset_pressed()` 到 `_on_ultra_preset_pressed()` 提供 5 档一键预设，通过 `update_preset()` 模拟各选项被选中的信号。

**Compatibility 适配：** `_ready()` 中检测 Compatibility 渲染器，禁用不支持的选项（TAA、SSAO、SSR 等）。
