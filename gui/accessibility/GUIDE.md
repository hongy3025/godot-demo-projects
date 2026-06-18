# UI Accessibility - 源代码导读

> 本文档面向 Godot 新手，逐层剖析 UI 无障碍功能的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**UI Accessibility**（Godot 4.6）

演示 Godot 的 UI 无障碍（Accessibility）功能，包括：
- 基本无障碍支持（焦点管理、屏幕阅读器）
- 自定义 Control 节点的无障碍支持（通过 `DisplayServer` API）

---

## 2. 快速上手

运行 `controls.tscn` 主场景。Tab 键切换焦点，方向键操作自定义控件。

---

## 3. 核心架构

```
controls.tscn  ← 主场景，展示基本无障碍控件
  └── controls.gd  ← 焦点管理 + 实时区域更新
custom_control.gd  ← 自定义无障碍控件的完整实现
```

---

## 4. 文件逐层导读

### `controls.gd` — 基本无障碍控件

```gdscript
extends Control

func _ready() -> void:
    $LineEditName.grab_focus() # 无障碍 UI 必须始终有键盘焦点
```

- `_ready()` 自动将焦点赋给姓名输入框
- `_on_button_set_pressed()` 更新实时区域（Live Region）文本

### `custom_control.gd` — 自定义无障碍控件 ⭐

**核心文件。** 演示如何让自定义控件支持屏幕阅读器。

**关键数据结构：**
```gdscript
var item_aes: Array[RID] = [RID(), RID(), RID()]  # 无障碍子元素句柄
var item_names: Array[String] = ["Item 1", "Item 2", "Item 3"]
var item_values: Array[int] = [0, 0, 0]
```

**输入处理（`_gui_input`）：**
- 左右方向键切换选中项
- 上下方向键增减数值
- 每次变化调用 `queue_accessibility_update()` 通知屏幕阅读器

**无障碍通知（`_notification`）：**

`NOTIFICATION_ACCESSIBILITY_UPDATE` 中：
1. 获取无障碍元素句柄：`get_accessibility_element()`
2. 设置角色：`DisplayServer.accessibility_update_set_role(ae, ROLE_LIST_BOX)`
3. 创建子元素：`DisplayServer.accessibility_create_sub_element()`
4. 设置名称、值、范围、边界框
5. 注册操作：`ACTION_DECREMENT`、`ACTION_INCREMENT`、`ACTION_SET_VALUE`

**关键 API：**

| API | 用途 |
|-----|------|
| `queue_accessibility_update()` | 请求更新无障碍信息 |
| `get_accessibility_element()` | 获取主元素 RID |
| `accessibility_create_sub_element()` | 创建子元素 |
| `accessibility_update_add_action()` | 注册可操作动作 |
| `NOTIFICATION_ACCESSIBILITY_INVALIDATE` | 元素销毁时清理 |

---

## 5. 关键概念详解

### 5.1 无障碍元素树

```
主元素 (ROLE_LIST_BOX)
├── 子元素 0 (ROLE_LIST_BOX_OPTION) — "Item 1", 值 0
├── 子元素 1 (ROLE_LIST_BOX_OPTION) — "Item 2", 值 0
└── 子元素 2 (ROLE_LIST_BOX_OPTION) — "Item 3", 值 0
```

### 5.2 焦点与无障碍的关系

- `_get_focused_accessibility_element()` 返回当前聚焦的子元素 RID
- 屏幕阅读器通过此方法知道当前朗读哪个元素
- `NOTIFICATION_FOCUS_ENTER` / `EXIT` 触发重绘视觉反馈

### 5.3 操作（Actions）

屏幕阅读器可通过全局快捷键调用：
- `ACTION_DECREMENT` → 减少数值
- `ACTION_INCREMENT` → 增加数值
- `ACTION_SET_VALUE` → 设置指定数值
