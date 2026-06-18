# OpenXR Spectator View - 源代码导读

> 本文档面向 Godot 新手，讲解如何实现 VR 旁观者视角——头显内和屏幕上显示不同画面。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 VR 旁观者视角：VR 玩家在头显中看到第一人称画面，屏幕上的旁观者看到第三人称视角。支持多视角切换、摄像机追踪和激光指针交互。

---

## 2. 核心架构

```
spectator.tscn (桌面端) → 包含 VR 场景 + 旁观者相机
    ├── VRSubViewport → 渲染 VR 画面（输出到头显）
    │   └── Main (main.tscn) → VR 游戏逻辑
    └── SpectatorCamera → 第三人称相机（显示在屏幕）
        └── 可切换：第三人称 / 稳定第一人称 / 左眼 / 右眼
```

---

## 3. 文件逐层导读

### `spectator.gd` — 旁观者控制 ⭐

**视角切换：**

```gdscript
func _on_spectator_view_item_selected(index):
    match index:
        0: # 旁观者相机（第三人称）
            spectator_camera.current = true
            hmd_view.visible = false
        1: # 稳定第一人称
            stabilized_camera.current = true
        2: # 左眼画面
            hmd_view_material.set_shader_parameter("layer", 0)
        3: # 右眼画面
            hmd_view_material.set_shader_parameter("layer", 1)
```

**摄像机追踪：**

```gdscript
func _on_track_camera_toggled(toggled_on):
    if toggled_on:
        main_scene.tracked_camera = spectator_camera  # 由 Vive Tracker 控制位置
    else:
        main_scene.tracked_camera = null  # 用户手动控制
```

### `main.gd` — VR 场景逻辑

```gdscript
func _enable_pointer():
    # 切换左右手激光指针
    $XROrigin3D/LeftHandAim/XRPointer.enabled = left_or_right == 0
    $XROrigin3D/RightHandAim/XRPointer.enabled = left_or_right == 1
```

### `xr_pointer.gd` — 激光指针

```gdscript
class_name XRPointer
extends RayCast3D

func _process(_delta):
    if enabled and is_colliding():
        $Target.global_position = get_collision_point()
        # 通知目标对象指针进入/移动/退出
```

### `start_vr.gd` — OpenXR 初始化

提供 `get_vr_render_size()` 方法获取 VR 渲染尺寸。

---

## 4. 关键概念详解

### 视觉层分离

```
Layer 1 (Default): 头显 + 屏幕都可见
Layer 2 (VR only): 仅头显可见（如玩家身体）
Layer 3 (Spectator only): 仅屏幕可见（如玩家头部模型）
```

### 场景结构

```
桌面端: spectator.tscn
    └── VRSubViewport → 渲染到 VR 头显
        └── main.tscn → VR 游戏
    └── 主视口 → 渲染到屏幕
        └── SpectatorCamera → 第三人称

移动端: main.tscn（直接加载，无旁观者）
```
