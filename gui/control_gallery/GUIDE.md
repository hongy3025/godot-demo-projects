# Control Gallery - 源代码导读

> 本文档面向 Godot 新手，剖析 Control 节点画廊项目的结构与代码。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名称：**Control Gallery**（Godot 4.6）

展示 Godot 各种 Control 节点的外观和功能，每个控件都标注了名称。灵感来自 GTK 等 GUI 工具包的"控件画廊"。

3 个主面板（"Basic Controls"、"Numeric"、"List"）通过 `HSplitContainer` 和 `VSplitContainer` 分隔，可拖动调整大小。

---

## 2. 快速上手

运行 `control_gallery.tscn`。拖动面板之间的分隔条调整各区域大小。

---

## 3. 核心架构

```
control_gallery.tscn  ← 主场景，纯场景编辑器搭建
  └── tree.gd  ← Tree 控件脚本（@tool 模式）
```

本项目绝大部分功能通过场景编辑器直接完成，仅 Tree 控件有自定义脚本。

---

## 4. 文件逐层导读

### `tree.gd` — Tree 控件演示

```gdscript
@tool
extends Tree
```

**`@tool` 标记：** 脚本在编辑器中即可运行，场景中直接看到效果。

**`_ready()` 构建树结构：**
```gdscript
var root: TreeItem = create_item()
root.set_text(0, "Tree - Root TreeItem")
```

**按钮添加：**
```gdscript
root.add_button(0, ImageTexture.create_from_image(image), -1, false, "Example TreeItem button.")
```

- 从 `icon.webp` 加载图片，缩放到 16x16
- 创建两个按钮：一个正常、一个禁用

**树层级：**
```
Root
├── TreeItem 1
│   └── TreeItem 1 Child
└── TreeItem 2
```

### 场景中展示的 Control 节点

| 面板 | 控件 |
|------|------|
| Basic Controls | Button, CheckButton, CheckBox, ColorPickerButton, LinkButton, MenuButton, OptionButton, SpinBox, TextEdit, LineEdit, ProgressBar |
| Numeric | HSlider, VSlider, HScrollBar, VScrollBar, SpinBox |
| List | ItemList, Tree, TabContainer |
| 其他 | HSplitContainer, VSplitContainer, TabBar, PopupMenu |
