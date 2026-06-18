# WebXR Demo - 源代码导读

> 本文档面向 Godot 新手，讲解如何在浏览器中启用 WebXR VR 体验。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

一个极简的 WebXR 演示项目，展示如何在浏览器中实现 VR 渲染和控制器支持。用户点击"Enter VR"按钮进入沉浸式 VR 模式。

---

## 2. 核心架构

```
main.gd → WebXR 初始化和管理
    ├── 检测浏览器是否支持 VR
    ├── 请求沉浸式 VR 会话
    ├── 处理控制器输入
    └── 处理会话生命周期
```

---

## 3. 文件逐层导读

### `main.gd` — 核心逻辑 ⭐

**初始化：**

```gdscript
func _ready() -> void:
    webxr_interface = XRServer.find_interface("WebXR")
    if webxr_interface:
        # 连接异步回调信号
        webxr_interface.session_supported.connect(_webxr_session_supported)
        webxr_interface.session_started.connect(_webxr_session_started)
        webxr_interface.session_ended.connect(_webxr_session_ended)
        webxr_interface.session_failed.connect(_webxr_session_failed)

        # 连接控制器事件
        webxr_interface.select.connect(_webxr_on_select)
        webxr_interface.squeeze.connect(_webxr_on_squeeze)

        # 检测是否支持 VR
        webxr_interface.is_session_supported("immersive-vr")
```

**进入 VR：**

```gdscript
func _on_enter_vr_button_pressed() -> void:
    webxr_interface.session_mode = "immersive-vr"
    webxr_interface.requested_reference_space_types = "bounded-floor, local-floor, local"
    webxr_interface.required_features = "local-floor"
    webxr_interface.optional_features = "bounded-floor"
    webxr_interface.initialize()
```

**会话生命周期：**

```gdscript
func _webxr_session_started() -> void:
    $CanvasLayer.visible = false
    get_viewport().use_xr = true  # 开始 VR 渲染

func _webxr_session_ended() -> void:
    $CanvasLayer.visible = true
    get_viewport().use_xr = false  # 恢复普通渲染
```

**控制器输入：**

```gdscript
func _process(_delta: float) -> void:
    var thumbstick_vector = left_controller.get_vector2(&"thumbstick")
    if thumbstick_vector != Vector2.ZERO:
        print("Left thumbstick position: " + str(thumbstick_vector))
```

---

## 4. 关键概念详解

### WebXR 会话模式

| 模式 | 说明 |
|------|------|
| `immersive-vr` | 完全沉浸式 VR |
| `immersive-ar` | AR 模式 |
| `viewer` | 简单 3DoF 查看器 |

### 参考空间类型

| 类型 | 说明 |
|------|------|
| `local` | 原点在 XROrigin3D 位置 |
| `local-floor` | 地面高度 1.6m（适合站立/坐姿） |
| `bounded-floor` | 房间尺度（带边界） |

### 导出配置

Web 导出时需要在 `Head Include` 中添加 WebXR Polyfill 脚本以兼容更多浏览器。
