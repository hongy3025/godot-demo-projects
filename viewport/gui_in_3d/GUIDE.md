# GUI in 3D - 源代码导读

> 本文档面向 Godot 新手，讲解如何在 3D 场景中嵌入可交互的 GUI 界面。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示如何在 3D 场景的四边形网格上显示 GUI，并将鼠标/键盘输入转发到该 GUI。核心思路是将 GUI 渲染到 `SubViewport`，通过 `Area3D` 检测鼠标交互，将 3D 坐标映射到 2D 视口坐标。

---

## 2. 核心架构

```
鼠标在 3D 场景中点击四边形
    ↓ Area3D 检测
3D 碰撞点坐标
    ↓ 坐标转换
2D 视口坐标
    ↓ push_input()
SubViewport 中的 GUI 接收事件
```

---

## 3. 文件逐层导读

### `gui_3d.gd` — 核心脚本 ⭐

**鼠标进入/离开检测：**

```gdscript
node_area.mouse_entered.connect(_mouse_entered_area)
node_area.mouse_exited.connect(_mouse_exited_area)
node_area.input_event.connect(_mouse_input_event)
```

**3D→2D 坐标转换流程：**

```gdscript
# 1. 获取 3D 碰撞点
var event_pos3D := event_position

# 2. 转换到 Area3D 局部空间
event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

# 3. 映射到 2D 坐标 (-0.5 ~ 0.5)
event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)
event_pos2D.x = event_pos2D.x / quad_mesh_size.x
event_pos2D.y = event_pos2D.y / quad_mesh_size.y

# 4. 映射到 0~1 范围
event_pos2D += 0.5

# 5. 映射到视口像素坐标
event_pos2D *= node_viewport.size

# 6. 将事件推送到视口
node_viewport.push_input(input_event)
```

**非鼠标事件转发：** 键盘事件通过 `_unhandled_input()` 直接 `push_input()` 到视口。

**Billboard 支持：** 如果材质启用了 Billboard 模式，`rotate_area_to_billboard()` 会同步旋转 Area3D 以匹配材质朝向。

---

## 4. 关键概念详解

### 坐标转换流水线

```
3D 世界坐标
    → affine_inverse() → Area3D 局部坐标
    → / mesh_size → 归一化坐标 (-0.5 ~ 0.5)
    → +0.5 → UV 坐标 (0 ~ 1)
    → × viewport.size → 视口像素坐标
```

### 事件类型处理

| 事件类型 | 处理方式 |
|----------|----------|
| 鼠标点击/移动 | 通过 Area3D 的 `input_event` 信号，经坐标转换后推送 |
| 键盘事件 | 通过 `_unhandled_input()` 直接推送 |
