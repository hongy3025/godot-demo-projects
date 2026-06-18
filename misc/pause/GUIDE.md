# 暂停演示 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中实现游戏暂停功能"。

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

这是一个 **Godot 4.6** 的暂停功能演示项目。核心目的是：

> **展示如何通过 `SceneTree.paused` 暂停游戏，以及如何使用 `process_mode` 控制哪些节点在暂停时继续运行。**

关键概念：
- `get_tree().paused = true` — 暂停场景树
- `Node.PROCESS_MODE_ALWAYS` — 暂停时仍然处理
- `AnimationPlayer.process_mode` — 控制动画在暂停时的行为

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `spinpause.tscn`。

### 2.2 操作说明

| 操作 | 功能 |
|------|------|
| P 键 / Pause 按钮 | 切换暂停/继续 |
| Process Mode 下拉框 | 选择动画在暂停时的处理模式 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          UI 层（不受暂停影响）        │
│  PauseButton (PROCESS_MODE_ALWAYS)   │
├──────────────────────────────────────┤
│          游戏逻辑层（受暂停影响）     │
│  旋转的立方体 / 动画                 │
├──────────────────────────────────────┤
│         Godot 暂停系统               │
│  SceneTree.paused                    │
│  Node.process_mode                   │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `pause_button.gd` — 暂停按钮 ⭐

**地位：** 项目的核心，控制暂停状态的切换。

```gdscript
extends Button

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func _toggled(is_button_pressed: bool) -> void:
    get_tree().paused = is_button_pressed
    if is_button_pressed:
        text = "Unpause"
    else:
        text = "Pause"
```

**关键点：**

| 行 | 说明 |
|----|------|
| `process_mode = PROCESS_MODE_ALWAYS` | 暂停时此按钮仍然响应输入 |
| `get_tree().paused = is_button_pressed` | 切换场景树的暂停状态 |

> **新手提示：** 如果不设置 `PROCESS_MODE_ALWAYS`，暂停后按钮本身也会停止响应，玩家将无法取消暂停。

### 4.2 `process_mode.gd` — 动画处理模式选择

**地位：** 演示 `AnimationPlayer.process_mode` 的不同选项。

```gdscript
extends OptionButton

@onready var cube_animation: AnimationPlayer = $"../../AnimationPlayer"

func _on_option_button_item_selected(index: int) -> void:
    cube_animation.process_mode = index as ProcessMode
```

**动画处理模式选项：**

| 索引 | 模式 | 暂停时行为 |
|------|------|-----------|
| 0 | `PROCESS_MODE_INHERIT` | 继承父节点设置（默认暂停） |
| 1 | `PROCESS_MODE_ALWAYS` | 暂停时继续播放 |
| 2 | `PROCESS_MODE_WHEN_PAUSED` | 仅在暂停时播放 |
| 3 | `PROCESS_MODE_DISABLED` | 从不处理 |

---

## 5. 关键概念详解

### 5.1 SceneTree.paused

当 `paused = true` 时：
- 所有 `_process()` 和 `_physics_process()` 停止调用
- 所有 `AnimationPlayer` 暂停播放
- 物理模拟停止
- 输入处理停止

但以下节点不受影响：
- `process_mode = PROCESS_MODE_ALWAYS` 的节点
- `process_mode = PROCESS_MODE_WHEN_PAUSED` 的节点

### 5.2 Process Mode 枚举

| 模式 | 正常时 | 暂停时 |
|------|--------|--------|
| `INHERIT` | ✓ | 继承父节点 |
| `ALWAYS` | ✓ | ✓ |
| `WHEN_PAUSED` | ✗ | ✓ |
| `DISABLED` | ✗ | ✗ |

### 5.3 暂停的层级传递

子节点默认继承父节点的 `process_mode`。设置 `PROCESS_MODE_ALWAYS` 的父节点，其子节点也默认在暂停时继续运行。

---

## 6. 场景树全景

### 6.1 主场景 `spinpause.tscn`

```
SpinPause (Node2D)
├── Cube (Sprite2D)                    ← 旋转的立方体
├── AnimationPlayer                    ← 立方体旋转动画
├── PauseButton (Button)               ← 暂停/继续按钮
│   └── process_mode = ALWAYS
├── ProcessModeLabel (Label)
├── ProcessMode (OptionButton)         ← 动画处理模式选择
└── ... (其他装饰元素)
```

---

## 7. 如何扩展

### 7.1 暂停时显示菜单

创建一个暂停菜单面板，设置 `process_mode = PROCESS_MODE_ALWAYS`：

```gdscript
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    hide()  # 初始隐藏

func _on_pause_toggled(paused: bool) -> void:
    visible = paused
```

### 7.2 暂停时冻结特定节点

设置特定节点的 `process_mode = PROCESS_MODE_DISABLED`，使其在暂停和正常时都不运行。

### 7.3 暂停音效

使用 `AudioStreamPlayer` 的 `process_mode` 控制暂停时是否继续播放音乐。

---

## 推荐阅读路径

1. **`pause_button.gd`** — 理解暂停的核心逻辑
2. **`process_mode.gd`** — 理解动画处理模式
3. **`spinpause.tscn`** — 查看场景树结构
