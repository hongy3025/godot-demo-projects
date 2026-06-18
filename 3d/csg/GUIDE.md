# 构造实体几何 (CSG) - 源代码导读

> 本文档面向 Godot 新手，剖析 CSG 演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Constructive Solid Geometry (CSG)**（`project.godot` 中 `config/name`）

演示 Godot 的 CSG（构造实体几何）功能，用于在 3D 编辑器中快速原型化关卡设计。

主场景：`csg.tscn`

## 2. 快速上手

运行后左右箭头键切换不同的 CSG 测试示例。鼠标拖拽旋转视角，滚轮缩放。

## 3. 核心架构

```
csg.tscn
├── Testers (Node3D)          ← 多个 CSG 测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
├── DirectionalLight3D
└── UI (Control)
    ├── TestName
    ├── Previous / Next
    └── ...
```

## 4. 文件逐层导读

### `csg.gd` — 主控脚本

与 `anti_aliasing.gd` 结构类似，但更简洁。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化摄像机，检测 Compatibility 渲染器并适配光照 |
| `_unhandled_input()` | 鼠标旋转/缩放，切换测试对象 |
| `_process()` | 平滑移动摄像机到当前测试对象 |
| `update_gui()` | 更新 UI 文本和按钮状态 |

**CSG 测试内容：** 场景中的 `Testers` 节点下包含多个 CSG 组合体示例，展示 CSGBox3D、CSGSphere3D、CSGCylinder3D、CSGTorus3D 等基本体及其布尔运算（并集、差集、交集）。

### CSG 的核心节点

| 节点 | 用途 |
|------|------|
| `CSGBox3D` | 长方体 CSG 体 |
| `CSGSphere3D` | 球体 CSG 体 |
| `CSGCylinder3D` | 圆柱体 CSG 体 |
| `CSGTorus3D` | 圆环体 CSG 体 |
| `CSGCombiner3D` | CSG 组合器，用于布尔运算 |

CSG 节点通过 `operation` 属性控制布尔运算模式（Union、Intersection、Subtraction）。
