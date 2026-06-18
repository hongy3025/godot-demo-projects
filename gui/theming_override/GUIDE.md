# GUI Theming Override - 源代码导读

> 本文档面向 Godot 新手，剖析运行时覆盖 GUI 颜色和样式盒的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**GUI Theming Override**（Godot 4.6）

演示如何在运行时覆盖 GUI 颜色和样式盒（StyleBox），实现动态主题切换。

---

## 2. 快速上手

运行 `test.tscn`。点击"Button 1"或"Button 2"改变按钮边框和文字颜色，点击"Reset All"恢复。

---

## 3. 核心架构

```
test.tscn  ← 主场景
  └── test.gd  ← 主题覆盖逻辑
```

---

## 4. 文件逐层导读

### `test.gd` — 主题覆盖 ⭐

**`_ready()`：** 自动聚焦第一个按钮，方便键盘/手柄导航。

**`_on_button_pressed()` 黄色主题：**
```gdscript
var new_stylebox_normal: StyleBoxFlat = button.get_theme_stylebox(&"normal").duplicate()
new_stylebox_normal.border_color = Color(1, 1, 0)
button.add_theme_stylebox_override(&"normal", new_stylebox_normal)
label.add_theme_color_override(&"font_color", Color(1, 1, 0.375))
```

**`_on_button2_pressed()` 绿色主题：**
- 同样方式修改 `button2` 的边框为绿色
- 修改 `label` 文字颜色为浅绿色

**`_on_reset_all_button_pressed()` 重置：**
```gdscript
button.remove_theme_stylebox_override(&"normal")
label.remove_theme_color_override(&"font_color")
```

---

## 5. 关键概念详解

### 5.1 主题覆盖 API

| 方法 | 用途 |
|------|------|
| `add_theme_stylebox_override(name, stylebox)` | 覆盖样式盒 |
| `remove_theme_stylebox_override(name)` | 移除样式盒覆盖 |
| `add_theme_color_override(name, color)` | 覆盖颜色 |
| `remove_theme_color_override(name)` | 移除颜色覆盖 |
| `get_theme_stylebox(name)` | 获取当前样式盒 |

### 5.2 为什么需要 duplicate()

StyleBox 是引用类型，直接修改会影响所有使用该主题的控件。`duplicate()` 创建独立副本。

### 5.3 按钮三种状态

按钮需要同时覆盖三种状态的样式盒：
- `normal` — 正常状态
- `hover` — 悬停状态
- `pressed` — 按下状态

### 5.4 不使用 set() 的原因

```gdscript
# 错误方式：
set("custom_styles/normal", ...)
# 正确方式：
add_theme_stylebox_override("normal", ...)
```
自定义主题项属性不是常规的 Object 属性，必须使用 `add_theme_*_override` 方法。
