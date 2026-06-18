# OpenXR Render Models - 源代码导读

> 本文档面向 Godot 新手，讲解如何显示 VR 控制器的 3D 模型。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 OpenXR 渲染模型 API，自动加载并显示当前使用的 VR 控制器的 3D 模型。支持物理碰撞检测，让控制器可以与场景中的物体交互。

---

## 2. 核心架构

```
OpenXRRenderModelManager → 自动管理所有控制器模型
    ↓
每个 XRController3D 下挂载 OpenXRRenderModel
    ↓
collision_hands.gd → 物理碰撞体（跟随控制器）
```

---

## 3. 文件逐层导读

### `collision_hands.gd` — 物理碰撞 ⭐

```gdscript
class_name CollisionHands3D
extends AnimatableBody3D

func _ready():
    top_level = true
    sync_to_physics = false
    process_physics_priority = -90

func _physics_process(_delta):
    var dest_transform = get_parent().global_transform
    global_basis = dest_transform.basis
    move_and_collide(dest_transform.origin - global_position)
```

**关键点：**
- `top_level = true` — 不受父节点变换影响
- `move_and_collide()` — 跟随控制器位置，同时保持物理碰撞
- 用于实现"用手推箱子"等物理交互

### `start_vr.gd` — 标准 OpenXR 初始化

---

## 4. 关键概念详解

### 渲染模型 API 工作流程

```
OpenXR 运行时报告当前使用的控制器型号
    ↓
OpenXRRenderModelManager 查询控制器 3D 模型
    ↓
加载模型并附加到 XRController3D 节点
    ↓
每帧更新模型位置和组件状态
```

### 两种使用方式

| 方式 | 说明 |
|------|------|
| 全局管理 | 在 XROrigin3D 下添加 `OpenXRRenderModelManager`，自动处理所有控制器 |
| 逐控制器 | 在每个 XRController3D 下添加 `OpenXRRenderModel`，精细控制 |
