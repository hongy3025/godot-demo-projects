# Heart Custom Node - 源代码导读

> 本文档面向 Godot 新手，讲解如何通过插件创建自定义节点类型。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

这是一个极简的 Godot 编辑器插件，演示如何使用 `add_custom_type()` 在编辑器中注册一个名为 **Heart** 的自定义 2D 节点。Heart 节点会在画布中心绘制一个心形图标。

**核心文件：** 仅 3 个文件（`plugin.cfg`、`heart_plugin.gd`、`heart.gd`）+ 1 张贴图。

---

## 2. 核心架构

```
plugin.cfg → 声明插件元信息
    ↓
heart_plugin.gd → 插件入口，注册自定义类型
    ↓
heart.gd → 自定义节点的脚本逻辑
    ↓
heart.png → 心形图标纹理
```

---

## 3. 文件逐层导读

### `plugin.cfg`

```ini
[plugin]
name="Heart Plugin Demo"
description="Adds a new Heart node in 2D"
author="Juan Linietsky"
version="1.0"
script="heart_plugin.gd"
```

**字段说明：**
- `script` — 插件入口脚本路径，Godot 加载插件时会实例化此脚本

### `heart_plugin.gd` — 插件入口

```gdscript
@tool
extends EditorPlugin

func _enter_tree() -> void:
    var icon: Texture2D = preload("res://addons/custom_node/heart.png")
    add_custom_type("Heart", "Node2D", preload("res://addons/custom_node/heart.gd"), icon)

func _exit_tree() -> void:
    remove_custom_type("Heart")
```

**`add_custom_type` 参数：**
| 参数 | 值 | 说明 |
|------|-----|------|
| type | `"Heart"` | 节点类型名称，显示在"添加节点"对话框中 |
| base | `"Node2D"` | 继承的基类 |
| script | `heart.gd` | 附加到节点的脚本 |
| icon | `heart.png` | 节点图标 |

### `heart.gd` — 自定义节点脚本

```gdscript
@tool
extends Node2D

const HEART_TEXTURE := preload("res://addons/custom_node/heart.png")

func _draw() -> void:
    draw_texture(HEART_TEXTURE, -HEART_TEXTURE.get_size() / 2)

func _get_item_rect() -> Rect2:
    return Rect2(-HEART_TEXTURE.get_size() / 2, HEART_TEXTURE.get_size())
```

- `@tool` — 使脚本在编辑器中运行，实时渲染
- `_draw()` — 在节点中心绘制心形纹理
- `_get_item_rect()` — 返回节点的包围盒，用于编辑器选择框

---

## 4. 关键概念详解

### `@tool` 模式

`@tool` 让脚本在编辑器中运行。没有 `@tool`，自定义节点在编辑器中不会显示绘制内容。

### `add_custom_type` 的作用

- 在"添加节点"对话框的对应基类下注册新类型
- 创建节点时自动附加指定脚本
- 显示自定义图标
