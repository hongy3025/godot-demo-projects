# Mobile VR Stereo Interface Demo - 源代码导读

> 本文档面向 Godot 新手，讲解如何在移动设备上启用 VR 立体渲染。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)

---

## 1. 项目概述

最简单的 XR 演示项目，展示如何使用 Godot 内置的 `MobileVRInterface` 启用 VR 立体渲染。可在桌面端测试立体渲染效果，在移动设备上支持 3DOF 头部追踪。

---

## 2. 核心架构

```
main.gd → 初始化 MobileVRInterface
    ↓
XRServer.find_interface("Native mobile") → 获取接口
    ↓
interface.initialize() → 初始化
    ↓
viewport.use_xr = true → 启用 XR 渲染
```

---

## 3. 文件逐层导读

### `main.gd` — 核心逻辑

```gdscript
extends Node3D

func _ready():
    xr_interface = XRServer.find_interface("Native mobile")
    if xr_interface and xr_interface.initialize():
        var vp = get_viewport()
        vp.use_xr = true
        vp.vrs_mode = Viewport.VRS_XR
    else:
        get_tree().quit()
```

**关键步骤：**
1. `XRServer.find_interface("Native mobile")` — 查找移动 VR 接口
2. `initialize()` — 初始化接口
3. `viewport.use_xr = true` — 启用 XR 渲染（自动创建左右眼渲染目标）

**桌面移动控制：**

```gdscript
func _process(delta):
    # WASD 控制 XROrigin3D 移动
    $XROrigin3D.global_position += $XROrigin3D.global_transform.basis.x * dir.x * delta
    $XROrigin3D.global_position += $XROrigin3D.global_transform.basis.z * dir.y * delta
```

**场景树：**
```
Main (Node3D)
├── XROrigin3D
│   ├── XRCamera3D
│   └── MeshInstance3D (显示参考网格)
├── DirectionalLight3D
└── WorldEnvironment
```
