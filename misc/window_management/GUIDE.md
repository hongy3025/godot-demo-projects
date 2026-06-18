# 窗口管理 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用 DisplayServer 管理窗口"。

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

这是一个 **Godot 4.6** 的窗口管理演示项目。核心功能是：

> **通过 `DisplayServer` API 演示各种窗口管理功能，包括窗口移动、缩放、全屏、鼠标模式切换、多屏幕信息获取等。**

功能列表：
- 窗口移动和调整大小
- 全屏/窗口化切换
- 最小化/最大化
- 固定大小/可调整大小
- 鼠标模式切换（可见/隐藏/捕获/限制）
- 多屏幕信息（DPI、分辨率、刷新率）
- 窗口透明背景
- 3D 场景观察者（鼠标捕获模式下）

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `window_management.tscn`。

### 2.2 操作说明

| 按钮/按键 | 功能 |
|-----------|------|
| Move To | 将窗口移动到 (100, 100) |
| Resize | 将窗口大小设为 1280x720 |
| Screen 0/1 | 切换到指定屏幕 |
| Fullscreen | 切换全屏 |
| Fixed Size | 切换固定大小 |
| Minimized / Maximized | 最小化/最大化 |
| Mouse Mode 按钮 | 切换鼠标模式 |
| WASD | 鼠标捕获模式下移动观察者 |
| Esc | 鼠标捕获模式下退出捕获 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│           UI 控制层                   │
│  按钮 / 标签 / 复选框               │
├──────────────────────────────────────┤
│          窗口管理逻辑层              │
│  control.gd (DisplayServer API)      │
├──────────────────────────────────────┤
│          3D 场景层                   │
│  Observer (CharacterBody3D)          │
├──────────────────────────────────────┤
│         Godot 窗口系统               │
│  DisplayServer API                   │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `control.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，处理所有窗口管理操作和信息显示。

**关键变量：**

| 变量 | 说明 |
|------|------|
| `mouse_position` | 当前鼠标位置 |
| `observer` | 3D 场景中的观察者角色 |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | Web 平台禁用不支持的按钮，初始化屏幕信息 |
| `_physics_process()` | 每帧更新窗口状态信息 |
| `_input(event)` | 处理键盘快捷键和鼠标移动 |
| `check_wm_api()` | 检查当前平台是否支持窗口管理 API |

**窗口状态显示（`_physics_process` 中）：**

```gdscript
var modetext: String = "Mode: "
if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
    modetext += "Fullscreen\n"
# ... 检查最小化、最大化、鼠标模式等
```

**多屏幕信息：**

```gdscript
$Labels/Label_Screen0_DPI.text = str("Screen0 DPI: ", DisplayServer.screen_get_dpi())
if DisplayServer.get_screen_count() > 1:
    $Labels/Label_Screen1_Resolution.text = str("Screen1 Resolution:\n", DisplayServer.screen_get_size(1))
```

**API 可用性检查：**

```gdscript
func check_wm_api() -> bool:
    if not DisplayServer.has_method(&"get_screen_count"):
        s += " - get_screen_count()\n"
    # ... 检查所有方法
```

### 4.2 `observer/observer.gd` — 3D 观察者

**地位：** 鼠标捕获模式下的 3D 场景漫游控制器。

**状态枚举：**

```gdscript
enum State {
    MENU,   # 菜单模式（鼠标可见）
    GRAB,   # 捕获模式（鼠标隐藏，WASD 移动）
}
```

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_process(delta)` | WASD 移动和鼠标视角旋转 |
| `_input(event)` | 处理鼠标移动和 Esc 切换模式 |

**移动逻辑：**

```gdscript
var x_movement := Input.get_axis(&"move_left", &"move_right")
var z_movement := Input.get_axis(&"move_forward", &"move_backwards")
var dir := direction(Vector3(x_movement, 0, z_movement))
transform.origin += dir * 10 * delta
```

**透明窗口切换：**

```gdscript
func _on_transparent_check_button_toggled(button_pressed: bool) -> void:
    get_viewport().transparent_bg = button_pressed
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, button_pressed)
```

---

## 5. 关键概念详解

### 5.1 DisplayServer API

`DisplayServer` 是 Godot 4 中用于窗口和显示管理的核心类，取代了 Godot 3 中 `OS` 类的相关功能。

| 方法 | 功能 |
|------|------|
| `window_set_position()` | 设置窗口位置 |
| `window_set_size()` | 设置窗口大小 |
| `window_set_mode()` | 设置窗口模式（全屏/窗口化/最小化/最大化） |
| `window_set_flag()` | 设置窗口标志（固定大小/透明） |
| `screen_get_dpi()` | 获取屏幕 DPI |
| `screen_get_refresh_rate()` | 获取屏幕刷新率 |

### 5.2 鼠标模式

| 模式 | 说明 |
|------|------|
| `MOUSE_MODE_VISIBLE` | 鼠标可见，正常行为 |
| `MOUSE_MODE_HIDDEN` | 鼠标隐藏但仍可移动 |
| `MOUSE_MODE_CAPTURED` | 鼠标捕获，无法移出窗口 |
| `MOUSE_MODE_CONFINED` | 鼠标限制在窗口内 |
| `MOUSE_MODE_CONFINED_HIDDEN` | 鼠标隐藏并限制在窗口内 |

### 5.3 窗口模式

| 模式 | 说明 |
|------|------|
| `WINDOW_MODE_WINDOWED` | 窗口模式 |
| `WINDOW_MODE_FULLSCREEN` | 全屏模式 |
| `WINDOW_MODE_MINIMIZED` | 最小化 |
| `WINDOW_MODE_MAXIMIZED` | 最大化 |

### 5.4 平台兼容性

Web 平台不支持部分窗口管理功能，项目通过 `OS.has_feature("web")` 检测并禁用相应按钮。

---

## 6. 场景树全景

### 6.1 主场景 `window_management.tscn`

```
WindowManagement (Control)
├── Buttons (VBoxContainer)            ← 窗口操作按钮
│   ├── Button_MoveTo
│   ├── Button_Resize
│   ├── Button_Screen0/1
│   ├── Button_Fullscreen
│   ├── Button_FixedSize
│   ├── Button_Minimized/Maximized
│   └── MouseMode 按钮组
├── Labels (VBoxContainer)             ← 信息显示标签
│   ├── Label_Mode
│   ├── Label_Position
│   ├── Label_Size
│   ├── Label_MousePosition
│   ├── Label_Screen_Count
│   └── Label_Screen0/1_*
├── CheckButton                        ← 透明窗口开关
├── ImplementationDialog (AcceptDialog)
└── Observer (CharacterBody3D)         ← 3D 场景观察者
    └── Camera3D
```

---

## 7. 如何扩展

### 7.1 添加更多窗口操作

在 `control.gd` 中添加新的按钮处理方法，使用 `DisplayServer` API：

```gdscript
func _on_button_center_pressed() -> void:
    var screen_size := DisplayServer.screen_get_size()
    var window_size := DisplayServer.window_get_size()
    var center := (screen_size - window_size) / 2
    DisplayServer.window_set_position(center)
```

### 7.2 支持更多鼠标模式

`Input.MOUSE_MODE_CONFINED_HIDDEN` 已包含在项目中，可以扩展更多模式。

### 7.3 窗口事件监听

连接 `DisplayServer` 的窗口事件信号，如 `window_event`，响应窗口状态变化。

---

## 推荐阅读路径

1. **`control.gd`** — 理解窗口管理的核心逻辑
2. **`observer/observer.gd`** — 看 3D 场景与窗口管理的结合
3. **`project.godot`** — 查看输入映射和窗口配置
