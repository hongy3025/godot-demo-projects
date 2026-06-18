# 多窗口演示 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用 Window 类和相关对话框"。

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

这是一个 **Godot 4.6** 的多窗口演示项目。核心功能是：

> **展示所有 Window 类及其子类在主窗口中的使用，包括子窗口嵌入/取消嵌入、对话框、弹出菜单、系统托盘等。**

功能列表：
- 嵌入/取消嵌入子窗口
- 透明窗口
- 向新窗口添加物理对象
- 所有对话框窗口展示（AcceptDialog、ConfirmationDialog、FileDialog）
- 所有弹出窗口展示（Popup、PopupMenu、PopupPanel）
- 系统托盘图标

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `scenes/main_scene.tscn`。

### 2.2 操作说明

| 功能 | 说明 |
|------|------|
| Embed Subwindows | 切换子窗口嵌入模式 |
| Window / Draggable Window | 打开子窗口 |
| Transient / Exclusive / Unresizable / Borderless / Always on Top / Transparent | 子窗口属性切换 |
| File Dialog | 打开文件选择对话框 |
| Accept Dialog / Confirmation Dialog | 打开确认对话框 |
| Popup / Popup Menu / Popup Panel | 打开弹出窗口 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          主窗口 UI 层                │
│  控制按钮 / 输出显示                 │
├──────────────────────────────────────┤
│          窗口管理层                  │
│  Window / Popup / Dialog 等子类      │
├──────────────────────────────────────┤
│         Godot 窗口系统               │
│  Window 类 / gui_embed_subwindows    │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `scenes/main_scene.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，管理所有窗口的创建和交互。

**关键变量：**

| 变量 | 类型 | 说明 |
|------|------|------|
| `window` | `Window` | 主演示窗口 |
| `draggable_window` | `Window` | 可拖拽窗口 |
| `file_dialog` | `FileDialog` | 文件选择对话框 |
| `accept_dialog` | `AcceptDialog` | 确认对话框 |
| `confirmation_dialog` | `ConfirmationDialog` | 确认对话框（带取消） |
| `popup` | `Popup` | 弹出窗口 |
| `popup_menu` | `PopupMenu` | 弹出菜单 |
| `popup_panel` | `PopupPanel` | 弹出面板 |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `embed_subwindows(state)` | 切换子窗口嵌入模式 |
| `show_popup(popup)` | 在鼠标位置显示弹出窗口 |

**子窗口嵌入：**

```gdscript
func embed_subwindows(state: bool) -> void:
    get_viewport().gui_embed_subwindows = state
```

当 `gui_embed_subwindows = true` 时，子窗口被限制在主窗口内部显示；为 `false` 时，子窗口可以独立于主窗口移动。

**弹出窗口定位：**

```gdscript
func show_popup(_popup: Popup):
    var mouse_position
    if get_viewport().gui_embed_subwindows:
        mouse_position = get_global_mouse_position()
    else:
        mouse_position = DisplayServer.mouse_get_position()
    _popup.popup(Rect2(mouse_position, _popup.size))
```

嵌入模式下使用 Godot 坐标，非嵌入模式下使用屏幕坐标。

### 4.2 窗口属性控制

**窗口属性切换示例：**

```gdscript
func _on_transient_window_toggled(toggled_on: bool) -> void:
    window.transient = toggled_on  # 设置为临时窗口

func _on_exclusive_window_toggled(toggled_on: bool) -> void:
    window.exclusive = toggled_on  # 设置为独占窗口

func _on_transparent_window_toggled(toggled_on: bool) -> void:
    window.transparent = toggled_on  # 设置为透明窗口
```

### 4.3 其他辅助脚本

| 文件 | 说明 |
|------|------|
| `scenes/disable_other.gd` | 禁用其他控件的辅助脚本 |
| `scenes/text_field.gd` | 文本输入字段逻辑 |
| `scenes/status_indicator/` | 系统托盘状态指示器 |

---

## 5. 关键概念详解

### 5.1 Window 类体系

```
Window (根)
├── Popup
│   ├── PopupMenu
│   └── PopupPanel
├── AcceptDialog
│   └── ConfirmationDialog
└── FileDialog
```

### 5.2 嵌入 vs 非嵌入

| 模式 | 说明 |
|------|------|
| 嵌入 | 子窗口被限制在主窗口内，不能移出 |
| 非嵌入 | 子窗口是独立操作系统窗口，可以移出主窗口 |

### 5.3 窗口属性

| 属性 | 说明 |
|------|------|
| `transient` | 临时窗口，依赖父窗口 |
| `exclusive` | 独占窗口，阻止父窗口交互 |
| `unresizable` | 不可调整大小 |
| `borderless` | 无边框 |
| `always_on_top` | 始终置顶 |
| `transparent` | 透明背景 |

### 5.4 鼠标穿透多边形

`draggable_window` 使用 `mouse_passthrough_polygon` 实现部分区域鼠标穿透：

```gdscript
draggable_window.mouse_passthrough_polygon = [
    Vector2(16, 0), Vector2(16, 128),
    Vector2(116, 128), Vector2(116, 0)]
```

---

## 6. 场景树全景

### 6.1 主场景 `main_scene.tscn`

```
MainScene (Control)
├── Window                              ← 主演示子窗口
├── DraggableWindow                     ← 可拖拽子窗口
├── FileDialog                          ← 文件选择对话框
├── AcceptDialog                        ← 确认对话框
├── ConfirmationDialog                  ← 确认对话框（带取消）
├── Popup                               ← 弹出窗口
├── PopupMenu                           ← 弹出菜单
├── PopupPanel                          ← 弹出面板
├── StatusIndicator                     ← 系统托盘指示器
├── HBoxContainer
│   ├── VBoxContainer (控制按钮)
│   └── VBoxContainer2/3 (输出显示)
```

---

## 7. 如何扩展

### 7.1 添加新的窗口类型

在场景中添加新的 `Window` 子节点，在 `main_scene.gd` 中添加对应的引用和控制方法。

### 7.2 自定义对话框

继承 `AcceptDialog` 或 `ConfirmationDialog`，添加自定义内容和按钮：

```gdscript
extends AcceptDialog
func _ready() -> void:
    add_button("自定义操作", false, "custom_action")
```

### 7.3 系统托盘菜单

扩展 `StatusIndicator`，添加右键菜单功能。

---

## 推荐阅读路径

1. **`scenes/main_scene.gd`** — 理解窗口管理的核心逻辑
2. **`scenes/main_scene.tscn`** — 查看场景树结构
