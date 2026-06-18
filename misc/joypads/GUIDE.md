# 手柄演示 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中测试手柄输入和生成控制器映射字符串"。

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

这是一个 **Godot 4.6** 的手柄输入测试工具。核心功能是：

> **实时显示手柄的轴值、按钮状态，并提供映射向导用于生成 SDL 格式的控制器映射字符串。**

功能包括：
- 实时显示所有轴（摇杆、扳机）的当前值
- 实时显示所有按钮的按下状态
- 手柄连接/断开检测
- 手柄振动测试
- 映射向导（生成控制器映射字符串）
- 手柄外观示意图

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `joypads.tscn`。

### 2.2 操作说明

| 功能 | 说明 |
|------|------|
| Joy Number | 选择要测试的手柄编号 |
| 轴进度条 | 显示每个轴的当前值（-1~1） |
| 按钮网格 | 高亮显示按下的按钮 |
| Start/Stop Vibration | 开始/停止手柄振动 |
| Remap | 打开映射向导 |
| Show | 显示生成的映射字符串 |
| Clear | 清除当前手柄的映射 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│           UI 显示层                   │
│  轴进度条 / 按钮网格 / 手柄示意图    │
├──────────────────────────────────────┤
│          手柄数据处理层              │
│  _process() 轮询轴值和按钮状态       │
├──────────────────────────────────────┤
│         Godot 手柄 API 层            │
│  Input.get_joy_axis()                │
│  Input.is_joy_button_pressed()       │
│  Input.joy_connection_changed        │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `joypads.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，处理所有手柄输入检测和 UI 更新。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `DEADZONE` | 0.2 | 死区阈值，小于此值的轴输入被忽略 |
| `FONT_COLOR_DEFAULT` | `Color(1,1,1,0.5)` | 非激活状态的字体颜色 |
| `FONT_COLOR_ACTIVE` | `Color(0.2,1,0.2,1)` | 激活状态的字体颜色（绿色） |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 连接 `joy_connection_changed` 信号，列出已连接手柄 |
| `_process()` | 每帧轮询所有轴和按钮状态，更新 UI |
| `_on_joy_connection_changed()` | 手柄连接/断开时触发，更新显示 |

**轴值处理逻辑（`_process` 中）：**

```gdscript
for axis in range(int(min(JOY_AXIS_MAX, 10))):
    axis_value = Input.get_joy_axis(joy_num, axis)
    axes.get_node("Axis" + str(axis) + "/ProgressBar").set_value(100 * axis_value)
```

**死区处理：**

```gdscript
var scaled_alpha_value = (abs(axis_value) - DEADZONE) / (1.0 - DEADZONE)
```

将死区外的轴值映射到 0~1 范围，用于控制手柄示意图上指示器的透明度。

**按钮处理逻辑：**

```gdscript
for button in range(int(min(JOY_BUTTON_SDL_MAX, 21))):
    if Input.is_joy_button_pressed(joy_num, button):
        button_grid.get_child(button).add_theme_color_override(&"font_color", FONT_COLOR_ACTIVE)
```

### 4.2 `remap/remap_wizard.gd` — 映射向导 ⭐

**地位：** 手柄映射生成工具，引导用户逐个映射所有按键和轴。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `start(idx)` | 开始映射向导 |
| `_input(event)` | 捕获手柄输入事件并记录映射 |
| `create_mapping_string()` | 生成 SDL 格式的映射字符串 |
| `remap_and_close()` | 应用映射并关闭向导 |

**映射步骤：**
1. 遍历 `JoyMapping.BASE.keys()` 中的所有按键/轴
2. 等待用户按下对应的手柄按钮或移动摇杆
3. 记录映射关系
4. 生成 SDL 格式字符串

**生成的映射字符串格式：**
```
GUID,Name,leftx:b0,lefty:b1,platform:Windows
```

### 4.3 `remap/joy_mapping.gd` — 映射数据结构

**职责：** 定义 `JoyMapping` 类，封装单个按键/轴的映射信息。

**类型枚举：**
- `Type.NONE` — 未映射
- `Type.BTN` — 按钮
- `Type.AXIS` — 轴

**轴类型：**
- `Axis.HALF_PLUS` — 正半轴
- `Axis.HALF_MINUS` — 负半轴
- `Axis.FULL` — 全轴

---

## 5. 关键概念详解

### 5.1 死区（Deadzone）

手柄摇杆在物理上存在"漂移"问题，即使不触碰也可能有微小输入。死区（0.2）表示轴值绝对值小于 0.2 时视为无输入。

### 5.2 SDL 映射字符串

Godot 使用 SDL 的控制器映射格式，格式为：
```
GUID,名称,按键1:类型,按键2:类型,...,platform:平台
```

例如 Xbox 手柄的映射：
```
030000005e0400008e02000000007200,Xbox Controller,a:b0,b:b1,platform:Windows
```

### 5.3 手柄示意图

项目使用 `joypad_diagram.tscn` 中的 `Node2D` 图形来可视化手柄状态。轴和按钮的指示器通过 `self_modulate.a` 控制透明度，实时反映输入状态。

---

## 6. 场景树全景

### 6.1 主场景 `joypads.tscn`

```
Joypads (Control)
├── DeviceInfo
│   ├── JoyName (RichTextLabel)        ← 手柄名称和 GUID
│   └── JoyNumber (SpinBox)            ← 手柄编号选择
├── JoypadDiagram (Node2D)             ← 手柄示意图
│   ├── Axes (Node2D)                  ← 轴指示器
│   └── Buttons (Node2D)               ← 按钮指示器
├── Axes (VBoxContainer)               ← 轴值进度条列表
│   ├── Axis0 ~ Axis9 (HBoxContainer)
│   │   ├── Label
│   │   ├── ProgressBar
│   │   └── Value (Label)
├── Buttons
│   └── ButtonGrid (GridContainer)     ← 按钮状态网格
├── Vibration
│   ├── Weak/Strong (HSlider)
│   ├── Duration (HSlider)
│   ├── StartVibration (Button)
│   └── StopVibration (Button)
├── RemapWizard (Node)                 ← 映射向导
├── VBoxContainer
│   ├── Remap (Button)
│   ├── Show (Button)
│   └── Clear (Button)
```

---

## 7. 如何扩展

### 7.1 添加更多轴/按钮

在 `_process()` 中增加循环上限，并确保 UI 中有对应的控件。

### 7.2 自定义映射预设

在 `joy_mapping.gd` 中添加已知手柄的映射预设：

```gdscript
class JoyMapping:
    const XBOX = { ... }
    const XBOX_OSX = { ... }
    # 添加新的预设
    const PS5 = { ... }
```

### 7.3 支持更多手柄类型

在 `remap_wizard.gd` 中添加更多初始映射选项。

---

## 推荐阅读路径

1. **`joypads.gd`** — 理解手柄输入轮询的核心逻辑
2. **`remap/remap_wizard.gd`** — 看映射生成的工作流程
3. **`remap/joy_mapping.gd`** — 理解映射数据结构
