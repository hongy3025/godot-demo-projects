# 贴花 (Decals) - 源代码导读

> 本文档面向 Godot 新手，剖析贴花演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Decals**（`project.godot` 中 `config/name`）

展示 Godot 的 Decal 节点功能，演示不同贴花过滤模式的效果。

主场景：`test.tscn`

## 2. 快速上手

运行后按 **P** 键在鼠标指向位置放置红色贴花。左上角下拉菜单切换贴花过滤模式。左右箭头键切换测试对象。

## 3. 核心架构

```
test.tscn
├── Testers (Node3D)          ← 多个贴花测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
└── UI (Control)
```

## 4. 文件逐层导读

### `tester.gd` — 主控脚本

继承自 `WorldEnvironment`。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化摄像机位置 |
| `_unhandled_input()` | 鼠标旋转/缩放，P 键放置贴花 |
| `_process()` | 平滑移动摄像机 |
| `_on_decal_filter_mode_item_selected()` | 切换贴花过滤模式（调用 `RenderingServer.decals_set_filter()`） |

**贴花放置逻辑（`_unhandled_input` 中 `place_decal` 动作）：**
```gdscript
var origin := camera.global_position
var target := camera.project_position(get_viewport().get_mouse_position(), 100)
var query := PhysicsRayQueryParameters3D.create(origin, target)
var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
if not result.is_empty():
    var decal := preload("res://decal.tscn").instantiate()
    add_child(decal)
    decal.position = result["position"]
    decal.transform.basis = camera.global_transform.basis
```

### 贴花过滤模式

| 模式 | 说明 |
|------|------|
| Nearest | 最近邻过滤，适合像素风格 |
| Linear | 线性过滤（默认） |
| Linear Mipmaps | 带 Mipmap 的线性过滤，减少远处颗粒感 |
| Linear Mipmaps Anisotropic | 各向异性过滤，倾斜视角更清晰 |
