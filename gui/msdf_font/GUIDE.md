# Multi-channel Signed Distance Field Font Demo - 源代码导读

> 本文档面向 Godot 新手，剖析 MSDF 字体技术的实现与效果。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Multi-channel Signed Distance Field Font Demo**（Godot 4.6）

演示 MSDF（多通道有符号距离场）字体技术，使文本在任意缩放和旋转下保持清晰。

---

## 2. 快速上手

运行 `sdf_font_demo.tscn`。按 S 键在 MSDF 和传统字体之间切换，拖动滑块调整描边大小。

---

## 3. 核心架构

```
sdf_font_demo.tscn  ← 主场景
└── sdf_font_demo.gd  ← 字体切换和描边控制
```

字体文件：
- `montserrat_semibold.ttf` — 传统渲染字体
- `montserrat_semibold_msdf.ttf` — MSDF 渲染字体

---

## 4. 文件逐层导读

### `sdf_font_demo.gd` — 字体控制

**`_input(input_event)` 字体切换：**
```gdscript
func _input(input_event: InputEvent) -> void:
    if input_event.is_action_pressed(&"toggle_msdf_font"):
        if %FontLabel.get_theme_font(&"font").multichannel_signed_distance_field:
            %FontLabel.add_theme_font_override(&"font", preload("res://montserrat_semibold.ttf"))
        else:
            %FontLabel.add_theme_font_override(&"font", preload("res://montserrat_semibold_msdf.ttf"))
        update_label()
```

**关键属性：** `FontFile.multichannel_signed_distance_field` 判断当前字体是否为 MSDF。

**`update_label()` 更新状态显示：**
```gdscript
%FontMode.text = "Font rendering: %s" % (
    "MSDF" if %FontLabel.get_theme_font(&"font").multichannel_signed_distance_field else "Traditional"
)
```

**`_on_outline_size_value_changed(value)` 描边控制：**
```gdscript
%FontLabel.add_theme_constant_override(&"outline_size", int(value))
```

---

## 5. 关键概念详解

### 5.1 MSDF vs 传统字体

| 特性 | 传统渲染 | MSDF |
|------|----------|------|
| 缩放清晰度 | 需重新栅格化 | 任意缩放清晰 |
| 旋转效果 | 可能模糊 | 保持清晰 |
| 小字号 | 可能模糊 | 更清晰 |
| 文件大小 | 较小 | 较大（多通道纹理） |

### 5.2 字体切换方式

使用 `add_theme_font_override()` 在运行时替换字体，无需修改场景节点。

### 5.3 输入映射

按 S 键触发切换（`project.godot` 中定义 `toggle_msdf_font` 动作）。
