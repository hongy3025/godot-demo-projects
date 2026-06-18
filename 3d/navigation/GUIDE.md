# 3D 导航 - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 导航演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Navigation**（`project.godot` 中 `config/name`）

3D 场景的导航演示，角色能够在静态 3D 环境中寻路。导航路径使用线条绘制。

主场景：`navmesh.tscn`

## 2. 快速上手

鼠标左键点击地面设置目标位置，机器人角色自动寻路。鼠标中键/右键拖拽旋转视角。

## 3. 核心架构

```
navmesh.tscn
├── NavigationRegion3D        ← 导航网格区域
│   └── MeshInstance3D
├── RobotBase (Marker3D)      ← 机器人角色
│   ├── MeshInstance3D
│   ├── CollisionShape3D
│   └── NavigationAgent3D
├── CameraBase (Node3D)
│   └── Camera3D
└── DirectionalLight3D
```

## 4. 文件逐层导读

### `navmesh.gd` — 场景主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_unhandled_input()` | 鼠标左键点击 → 射线检测 → 获取导航网格最近点 → 设置目标位置 |

**导航查询核心代码：**
```gdscript
var closest_point_on_navmesh := NavigationServer3D.map_get_closest_point_to_segment(
    get_world_3d().navigation_map,
    camera_ray_start,
    camera_ray_end
)
_robot.set_target_position(closest_point_on_navmesh)
```

### `character.gd` — 角色导航

继承 `Marker3D`。

**关键属性：**
- `character_speed` — 移动速度（默认 10）
- `show_path` — 是否显示导航路径

**`_physics_process()` 核心逻辑：**
1. 检查 `NavigationAgent3D.is_navigation_finished()`
2. 获取下一个路径点：`_nav_agent.get_next_path_position()`
3. 向目标移动：`global_position.move_toward(next_position, delta * character_speed)`
4. 朝向移动方向：`look_at(global_position + offset, Vector3.UP)`

**`set_target_position()` 方法：**
```gdscript
func set_target_position(target_position: Vector3) -> void:
    _nav_agent.set_target_position(target_position)
    if show_path:
        var path := NavigationServer3D.map_get_path(navigation_map, start_position, target_position, true)
        _nav_path_line.draw_path(path)
```

### `line3d.gd` — 路径绘制

自定义 `Line3D` 类，使用 `ImmediateMesh` 绘制导航路径线条。
