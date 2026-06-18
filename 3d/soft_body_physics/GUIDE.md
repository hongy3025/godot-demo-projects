# 3D 软体物理 - 源代码导读

> 本文档面向 Godot 新手，剖析软体物理演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Soft Body Physics**（`project.godot` 中 `config/name`）

软体物理（可变形物体）示例，包括布料、盒子和球体。

主场景：`test.tscn`

## 2. 快速上手

**R** 重置，**C** 放置布料，**V** 放置轻盒子，**B** 放置重盒子。最多同时存在 10 个用户放置物体。

## 3. 核心架构

```
test.tscn
├── Testers (Node3D)          ← 多个软体测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
└── UI (Control)
```

## 4. 文件逐层导读

### `tester.gd` — 主控脚本

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_input()` | 处理 R/C/V/B 快捷键 |
| `_physics_process()` | 更新物理模拟 |

**放置物体逻辑：**
```gdscript
func place_soft_body(scene_path: String):
    var body = load(scene_path).instantiate()
    # 通过射线检测确定放置位置
    var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
    body.position = result["position"]
    add_child(body)
```

### SoftBody3D 特性

| 特性 | 说明 |
|------|------|
| 固定点 | 将软体固定在特定位置 |
| 冲量/力 | 向特定点施加力（如风） |
| 交互 | 与静态体、刚体、角色体交互 |
| 限制 | 软体之间不交互（相互穿过） |

### 布料材质

使用启用了 **Grow** 属性的 `BaseMaterial3D`，防止可见的穿透到表面中。

### 每点冲量计时器

展示如何将节点附加到 `SoftBody3D` 的特定点上，可用于粒子、网格或刚体跟随。
