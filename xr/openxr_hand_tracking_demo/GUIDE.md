# OpenXR Hand Tracking Demo - 源代码导读

> 本文档面向 Godot 新手，讲解 OpenXR 手部追踪的实现和回退方案。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 OpenXR 手部追踪 API，支持光学手部追踪和控制器推断两种数据源。包含手部骨骼动画、拾取交互、以及控制器回退方案。

---

## 2. 核心架构

```
hand_mesh.gd → 选择追踪源（手部追踪优先，控制器回退）
    ↓
XRNode3D + SkeletonModifier3D → 骨骼动画
    ↓
hand_controller.gd → 选择 palm_pose 或 grip_pose
    ↓
hand_info.gd → 显示追踪状态信息
    ↓
pickup/ → 拾取系统（Area3D + RigidBody3D）
```

---

## 3. 文件逐层导读

### `hand_mesh.gd` — 追踪源选择 ⭐

```gdscript
func _process(delta):
    # 优先使用手部追踪
    new_tracker = "/user/hand_tracker/left"  # 或 /right
    var hand_tracker := XRServer.get_tracker(new_tracker)
    if hand_tracker and hand_tracker.has_tracking_data:
        tracker = new_tracker
        return

    # 回退到控制器追踪
    new_tracker = "left_hand"  # 或 "right_hand"
    # 尝试 palm_pose，不支持则用 grip
    var xr_pose := controller_tracker.get_pose("palm_pose")
    if not xr_pose or xr_pose.tracking_confidence == NONE:
        pose = "grip"
```

### `hand_controller.gd` — 姿势选择

```gdscript
func _process(delta):
    var controller_tracker := XRServer.get_tracker(tracker)
    if controller_tracker:
        var xr_pose := controller_tracker.get_pose("palm_pose")
        if not xr_pose or xr_pose.tracking_confidence == NONE:
            pose = "grip"  # 回退到 grip pose
```

### `hand_info.gd` — 状态信息显示

显示当前追踪源（光学/控制器）、追踪置信度（高/低/无）、使用的姿势（palm/grip）。

### `xr_hand_fallback_modifier_3d.gd` — 手指动画回退

当手部追踪不可用时，根据 trigger 和 grip 输入驱动手指骨骼动画。

---

## 4. 关键概念详解

### 追踪源优先级

```
1. 光学手部追踪 (XRHandTracker) → 最佳效果
2. 控制器推断 (XRControllerTracker + palm_pose)
3. 控制器回退 (XRControllerTracker + grip_pose)
4. 手指动画回退 (根据 trigger/grip 输入)
```

### 手部追踪 vs 控制器追踪

| | 光学手部追踪 | 控制器推断 |
|---|---|---|
| 数据源 | 头显摄像头 | 控制器按钮/扳机 |
| 手指动画 | 真实骨骼数据 | 根据输入推断 |
| 交互方式 | 手势（捏合、抓取） | 按钮/扳机 |
| 适用场景 | Quest、Pico 等 | Valve Index 等 |
