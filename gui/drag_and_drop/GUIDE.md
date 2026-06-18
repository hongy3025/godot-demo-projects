# Drag & Drop (GUI) - 源代码导读

> 本文档面向 Godot 新手，剖析 GUI 拖放功能的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Drag & Drop (GUI)**（Godot 4.6）

演示 Godot GUI 的拖放功能：
- 拖拽颜色按钮到目标按钮，复制颜色
- 点击按钮手动调整颜色

---

## 2. 快速上手

运行 `drag_and_drop.tscn`。从任意颜色按钮拖拽到另一个按钮上释放。

---

## 3. 核心架构

```
drag_and_drop.tscn  ← 主场景
  └── drag_drop_script.gd  ← 拖放逻辑（继承 ColorPickerButton）
```

所有颜色按钮共享同一个脚本。

---

## 4. 文件逐层导读

### `drag_drop_script.gd` — 拖放逻辑 ⭐

**三个核心回调方法：**

#### `_get_drag_data(at_position: Vector2) -> Color`

拖拽开始时调用，返回拖拽数据：

```gdscript
func _get_drag_data(_at_position: Vector2) -> Color:
    var cpb := ColorPickerButton.new()
    cpb.color = color
    cpb.size = Vector2(80.0, 50.0)
    var preview := Control.new()
    preview.add_child(cpb)
    cpb.position = -0.5 * cpb.size
    set_drag_preview(preview)  # 设置拖拽预览
    return color               # 返回拖拽数据
```

#### `_can_drop_data(_at_position: Vector2, data: Variant) -> bool`

鼠标悬停时调用，判断是否可以放置：

```gdscript
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return typeof(data) == TYPE_COLOR
```

#### `_drop_data(_at_position: Vector2, data: Variant) -> void`

释放时调用，处理放置逻辑：

```gdscript
func _drop_data(_at_position: Vector2, data: Variant) -> void:
    color = data
```

---

## 5. 关键概念详解

### 5.1 拖放三件套

| 方法 | 调用时机 | 职责 |
|------|----------|------|
| `_get_drag_data` | 开始拖拽 | 返回数据 + 设置预览 |
| `_can_drop_data` | 拖拽悬停 | 校验数据是否可接受 |
| `_drop_data` | 释放 | 处理数据 |

### 5.2 拖拽预览

- `set_drag_preview()` 设置跟随鼠标的预览控件
- 预览控件需要是 Control 类型
- 通过 `position = -0.5 * size` 居中于鼠标
