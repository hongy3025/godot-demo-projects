# Navigation Polygon 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 Godot 2D 导航系统。角色通过 `NavigationAgent2D` 自动寻路到鼠标点击位置，绕过障碍物。

## 2. 快速上手

运行 `navigation.tscn`，在场景中任意位置点击左键，角色自动寻路到目标点。

## 3. 核心架构

```
navigation.tscn
├── NavigationRegion2D     ← 导航区域
│   └── NavigationPolygon  ← 导航多边形（定义可行走区域）
├── StaticBody2D ×N        ← 障碍物
└── Character (CharacterBody2D)
    └── NavigationAgent2D  ← 导航代理
```

## 4. 文件逐层导读

### `character.gd` — 导航角色 ⭐

```gdscript
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
    navigation_agent.path_desired_distance = 2.0
    navigation_agent.target_desired_distance = 2.0
    navigation_agent.debug_enabled = true

func set_movement_target(movement_target):
    navigation_agent.target_position = movement_target

func _physics_process(_delta):
    if navigation_agent.is_navigation_finished():
        return
    var next_path_position = navigation_agent.get_next_path_position()
    velocity = global_position.direction_to(next_path_position) * movement_speed
    move_and_slide()
```

**工作流程：**
1. 点击设置 `navigation_agent.target_position`
2. `NavigationServer2D` 自动计算路径
3. 每帧获取路径的下一个点，朝该点移动
4. 到达终点后 `is_navigation_finished()` 返回 true

## 5. 关键概念详解

### NavigationAgent2D

导航代理自动处理路径查询和更新。关键属性：
- `path_desired_distance`：距离路径多近视为"到达路径"
- `target_desired_distance`：距离目标多近视为"到达目标"
- `debug_enabled`：显示路径调试线

### NavigationRegion2D

定义可行走区域。`NavigationPolygon` 中绘制多边形，障碍物所在区域会被自动排除。

## 6. 场景树全景

```
Navigation (Node2D)
├── NavigationRegion2D
│   └── NavigationPolygon
├── StaticBody2D (Obstacles)
│   └── CollisionShape2D
└── Character (CharacterBody2D)
    ├── CollisionShape2D
    └── NavigationAgent2D
```

## 7. 如何扩展

- 动态更新导航区域（运行时添加/移除障碍物后调用 `NavigationServer2D.bake_from_source_geometry_data()`）
- 添加多个角色，各自独立寻路
- 结合 `AnimationPlayer` 实现角色行走动画
