# 多点触控视图 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中调试多点触控输入"。

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

这是一个 **Godot 4.6** 的多点触控调试器项目。核心功能是：

> **在屏幕上显示所有触控点的彩色圆点，帮助开发者调试多点触控输入。**

项目使用自动加载的 `TouchHelper` 单例追踪所有触控点，主场景在 `_draw()` 中渲染彩色圆点。

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

### 2.2 操作说明

在触控设备上触摸屏幕，每个触控点会显示为一个彩色圆点。在桌面端，鼠标可以模拟单指触控。

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          渲染层                       │
│  main.gd (_draw() 绘制圆点)          │
├──────────────────────────────────────┤
│          数据层（自动加载）           │
│  TouchHelper (追踪所有触控点位置)     │
├──────────────────────────────────────┤
│          输入层                       │
│  InputEventScreenTouch / Drag        │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `touch_helper.gd` — 触控追踪单例 ⭐

**地位：** 作为自动加载的单例，追踪所有触控点的位置。

```gdscript
extends Node

var state: Dictionary[int, Vector2] = {}

func _unhandled_input(input_event: InputEvent) -> void:
    if input_event is InputEventScreenTouch:
        if input_event.pressed:
            state[input_event.index] = input_event.position
        else:
            state.erase(input_event.index)
        get_viewport().set_input_as_handled()

    elif input_event is InputEventScreenDrag:
        state[input_event.index] = input_event.position
        get_viewport().set_input_as_handled()
```

**关键点：**

| 行 | 说明 |
|----|------|
| `state: Dictionary[int, Vector2]` | 触控点索引 → 位置的映射 |
| `input_event.index` | 触控点的唯一索引 |
| `set_input_as_handled()` | 标记输入已处理，避免其他节点重复处理 |

**自动加载配置（`project.godot`）：**

```ini
[autoload]
TouchHelper="*res://touch_helper.gd"
```

### 4.2 `main.gd` — 主场景渲染

**地位：** 每帧读取 `TouchHelper` 的状态并绘制触控点。

```gdscript
extends Node2D

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    var touch_helper: Node = $"/root/TouchHelper"
    for ptr_index: int in touch_helper.state.keys():
        var pos: Vector2 = touch_helper.state[ptr_index]
        var color := _get_color_for_ptr_index(ptr_index)
        color.a = 0.75
        draw_circle(pos, 40.0, color)
```

**颜色生成：**

```gdscript
func _get_color_for_ptr_index(index: int) -> Color:
    var x := (index % 7) + 1
    return Color(float(bool(x & 1)), float(bool(x & 2)), float(bool(x & 4)))
```

根据触控点索引生成唯一颜色，最多支持 7 种不同颜色。

---

## 5. 关键概念详解

### 5.1 自动加载单例

`TouchHelper` 作为自动加载（Singleton），在游戏启动时自动创建，全局可访问。其他节点通过 `$"/root/TouchHelper"` 访问。

### 5.2 触控点索引

每个触控点有一个唯一的 `index`，从 0 开始递增。手指抬起后索引可能被重用。

### 5.3 _unhandled_input vs _input

| 方法 | 说明 |
|------|------|
| `_input()` | 所有输入事件，包括已处理的 |
| `_unhandled_input()` | 仅未处理的输入事件 |

`TouchHelper` 使用 `_unhandled_input()` 并在处理后调用 `set_input_as_handled()`，避免与 UI 控件冲突。

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Node2D)                          ← 绘制触控点
```

非常简单的场景树，所有逻辑在脚本中完成。

---

## 7. 如何扩展

### 7.1 显示触控点信息

在圆点旁边显示触控点索引和坐标：

```gdscript
draw_string(font, pos + Vector2(45, 0), "Index: %d" % ptr_index)
```

### 7.2 触控点轨迹

记录触控点的历史位置，绘制轨迹线：

```gdscript
var trail := touch_helper.trails.get(ptr_index, [])
for i in range(trail.size() - 1):
    draw_line(trail[i], trail[i + 1], color, 2)
```

### 7.3 手势识别

在 `TouchHelper` 中添加手势识别逻辑，如长按、双击、滑动等。

---

## 推荐阅读路径

1. **`touch_helper.gd`** — 理解触控追踪的核心逻辑
2. **`main.gd`** — 看触控点的渲染方式
3. **`project.godot`** — 查看自动加载配置
