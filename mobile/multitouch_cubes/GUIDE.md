# 多点触控立方体演示 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用多点触控 API 实现手势控制"。

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

这是一个 **Godot 4.6** 的多点触控演示项目。核心功能是：

> **使用触控 API 实现多点触控输入和手势控制，支持单指旋转（X/Y 轴）和双指缩放+旋转（Z 轴）。**

此演示适用于支持触控的设备（手机或平板电脑），也支持鼠标模拟触控。

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

### 2.2 操作说明

| 手势 | 功能 |
|------|------|
| 单指拖拽 | 绕 X 轴和 Y 轴旋转立方体 |
| 双指捏合 | 缩放立方体 |
| 双指旋转 | 绕 Z 轴旋转立方体 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          手势识别层                   │
│  gesture_area.gd                     │
│  单指/双指状态管理                   │
├──────────────────────────────────────┤
│          触控输入层                   │
│  InputEventScreenTouch               │
│  InputEventScreenDrag                │
├──────────────────────────────────────┤
│          3D 渲染层                   │
│  立方体场景 (cube_scene.tscn)        │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `gesture_area.gd` — 手势控制脚本 ⭐

**地位：** 项目的核心，实现所有触控手势的识别和响应。

**导出变量：**

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `target` | - | 要控制的 3D 节点路径 |
| `min_scale` | 0.1 | 最小缩放比例 |
| `max_scale` | 3.0 | 最大缩放比例 |
| `one_finger_rot_x` | true | 启用单指 X 轴旋转 |
| `one_finger_rot_y` | true | 启用单指 Y 轴旋转 |
| `two_fingers_rot_z` | true | 启用双指 Z 轴旋转 |
| `two_fingers_zoom` | true | 启用双指缩放 |

**关键变量：**

| 变量 | 说明 |
|------|------|
| `base_state` | 手指按下时的初始位置字典 |
| `curr_state` | 手指当前的位置字典 |
| `base_xform` | 手指数量变化前的变换快照 |

**状态机：**

```
手指数量 = 0 → 等待触摸
手指数量 = 1 → 单指模式（旋转 X/Y）
手指数量 = 2 → 双指模式（缩放 + 旋转 Z）
```

**单指旋转逻辑：**

```gdscript
var unit_drag := _px2unit(base_state[base_state.keys()[0]] - input_event.position)
if one_finger_rot_x:
    target_node.global_rotate(Vector3.UP, deg_to_rad(180.0 * unit_drag.x))
if one_finger_rot_y:
    target_node.global_rotate(Vector3.RIGHT, deg_to_rad(180.0 * unit_drag.y))
```

**双指缩放逻辑：**

```gdscript
var base_segment := base_state[key0] - base_state[key1]
var new_segment := curr_state[key0] - curr_state[key1]
var base_scale := Vector3(base_xform.basis.x.x, ...).length()
var new_scale := clampf(base_scale * (new_segment.length() / base_segment.length()), min_scale, max_scale) / base_scale
target_node.set_transform(base_xform.scaled(new_scale * Vector3.ONE))
```

**双指旋转逻辑：**

```gdscript
var rot := new_segment.angle_to(base_segment)
target_node.global_rotate(Vector3.BACK, rot)
```

**像素到单位转换：**

```gdscript
func _px2unit(v: Vector2) -> Vector2:
    var shortest := minf(get_size().x, get_size().y)
    return v * (1.0 / shortest)
```

将像素位移转换为与视口大小无关的单位值。

---

## 5. 关键概念详解

### 5.1 状态管理策略

项目使用 `base_state` 和 `curr_state` 两个字典管理手指状态：
- `base_state`：手指按下或数量变化时的快照
- `curr_state`：手指当前的最新位置

手指数量变化时，将 `curr_state` 复制到 `base_state` 并保存 `base_xform`，避免累积误差。

### 5.2 双指手势计算

```
base_segment = 初始两指向量
new_segment = 当前两指向量

缩放比例 = new_segment长度 / base_segment长度
旋转角度 = new_segment与base_segment的夹角
```

### 5.3 鼠标模拟触控

项目启用了鼠标模拟触控：
```ini
[input_devices]
pointing/emulate_touch_from_mouse=true
```

在桌面端测试时，鼠标可以模拟单指触控。

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Control)
├── GestureArea (Control)              ← 手势识别区域
│   └── CubeScene (Node3D)             ← 目标 3D 场景
│       └── ... (立方体网格)
```

### 6.2 立方体场景 `cube_scene.tscn`

```
CubeScene (Node3D)
├── MeshInstance3D (多个立方体)
├── OmniLight3D
└── Camera3D
```

---

## 7. 如何扩展

### 7.1 添加更多手势

在 `_gui_input()` 中添加三指手势支持：

```gdscript
elif finger_count == 3:
    # 三指手势：平移
    var drag := curr_state.values()[0] - base_state.values()[0]
    target_node.global_translate(Vector3(drag.x, drag.y, 0) * 0.01)
```

### 7.2 控制不同目标

修改 `target` 导出变量，将手势控制应用到不同的 3D 节点。

### 7.3 调整灵敏度

修改 `deg_to_rad(180.0 * unit_drag.x)` 中的系数调整旋转灵敏度。

---

## 推荐阅读路径

1. **`gesture_area.gd`** — 理解多点触控手势的核心实现
2. **`cube_scene.tscn`** — 查看 3D 场景结构
3. **`project.godot`** — 查看触控相关设置
