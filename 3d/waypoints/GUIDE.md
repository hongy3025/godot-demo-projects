# 3D 航点 - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 航点演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Waypoints**（`project.godot` 中 `config/name`）

在 3D 世界中显示 GUI 元素（如标签）的示例，通过将 3D 位置投影到屏幕上直接显示，不依赖 Viewport 或 Sprite3D 节点。

主场景：`main.tscn`

## 2. 快速上手

WASD 移动，鼠标环顾。观察场景中漂浮的航点标签，超出视野时自动吸附到窗口边框。

## 3. 核心架构

```
main.tscn
├── Level (Node3D)            ← 关卡
│   ├── Ground (StaticBody3D)
│   └── Buildings / Objects
├── Player (CharacterBody3D)
├── Camera3D
├── Waypoints (Node3D)        ← 航点位置标记
└── UI (CanvasLayer)          ← GUI 层
    └── Waypoint (Control)    ← 航点 UI 元素
```

## 4. 文件逐层导读

### `main.gd` — 场景主控

初始化场景，检测 Compatibility 渲染器并适配光照。

### `camera.gd` — 摄像机控制

第一人称摄像机控制。

### `waypoint.gd` — 航点核心脚本 ⭐

**核心原理：** 将 3D 世界坐标投影到 2D 屏幕坐标。

```gdscript
func _process(delta):
    # 将 3D 位置投影到屏幕
    var screen_pos = camera.unproject_position(global_position)
    
    # 检查是否在屏幕内
    var viewport_size = get_viewport().size
    var on_screen = screen_pos.x >= 0 and screen_pos.x <= viewport_size.x \
                and screen_pos.y >= 0 and screen_pos.y <= viewport_size.y
    
    if on_screen:
        # 在屏幕内，直接显示
        ui_element.position = screen_pos
    else:
        # 在屏幕外，吸附到边框
        screen_pos.x = clamp(screen_pos.x, 0, viewport_size.x)
        screen_pos.y = clamp(screen_pos.y, 0, viewport_size.y)
        ui_element.position = screen_pos
```

### 关键技术点

| 技术 | 说明 |
|------|------|
| `camera.unproject_position()` | 将 3D 坐标转换为 2D 屏幕坐标 |
| 边框吸附 | 超出视野时吸附到窗口边缘 |
| 无 Viewport | 直接在 CanvasLayer 上绘制 GUI |
| 性能优势 | 比 Viewport 方案更高效 |
