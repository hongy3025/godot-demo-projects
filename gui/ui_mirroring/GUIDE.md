# UI Mirroring Demo - 源代码导读

> 本文档面向 Godot 新手，剖析 UI 镜像功能的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**UI Mirroring Demo**（Godot 4.6）

演示 Godot 的 UI 镜像功能——当切换到从右到左（RTL）语言（如阿拉伯语）时，UI 布局自动水平翻转。

---

## 2. 快速上手

运行 `ui_mirroring.tscn`。点击按钮在英语和阿拉伯语之间切换，观察 UI 布局镜像。

---

## 3. 核心架构

```
ui_mirroring.tscn  ← 主场景
  └── ui_mirroring.gd  ← 语言切换逻辑
```

---

## 4. 文件逐层导读

### `ui_mirroring.gd` — 语言切换

```gdscript
extends Control

func _ready() -> void:
    $Label.text = TranslationServer.get_locale()

func _on_Button_pressed() -> void:
    if TranslationServer.get_locale() != "ar":
        TranslationServer.set_locale("ar")
    else:
        TranslationServer.set_locale("en")
    $Label.text = TranslationServer.get_locale()
```

**核心逻辑：**
- `_ready()` 显示当前语言代码
- 按钮在 `en` 和 `ar` 之间切换
- `TranslationServer.set_locale("ar")` 触发 UI 镜像

---

## 5. 关键概念详解

### 5.1 UI 镜像原理

当语言设置为 RTL 语言（如阿拉伯语 `ar`、希伯来语 `he`）时，Godot 自动：
- 水平翻转 `Control` 节点的布局
- 文本对齐方向从 LTR 变为 RTL
- 无需手动调整每个控件的位置

### 5.2 布局要求

- 使用 `Control` 节点的锚点（Anchor）和容器（Container）进行布局
- 避免使用绝对定位
- `HSplitContainer`、`BoxContainer` 等容器自动适配

### 5.3 字体要求

RTL 语言需要包含对应字形的字体。项目中 `fonts/` 目录提供了 Noto 字体。

### 5.4 关键 API

- `TranslationServer.set_locale("ar")` — 切换语言
- `TranslationServer.get_locale()` — 获取当前语言
- Godot 自动处理 UI 镜像，无需额外代码
