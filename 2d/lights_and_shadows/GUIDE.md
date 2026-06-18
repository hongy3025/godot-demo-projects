# 2D Lights and Shadows - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示 Godot 2D 灯光和阴影系统的基本用法，使用 `PointLight2D`、`DirectionalLight2D` 和 `LightOccluder2D`。支持动态切换灯光和阴影质量。

## 2. 快速上手

运行 `light_shadows.tscn`，按 D 切换方向光，P 切换点光源，S 切换方向光阴影质量，H 切换点光源阴影质量。

## 3. 核心架构

```
light_shadows.tscn
├── DirectionalLight2D     ← 方向光（模拟太阳）
├── PointLight2D ×N        ← 多个点光源
├── LightOccluder2D ×N     ← 遮光体
└── Sprite2D ×N            ← 场景物体
```

## 4. 文件逐层导读

### `light_shadows.gd` — 灯光控制

```gdscript
func _input(input_event):
    if input_event.is_action_pressed(&"toggle_directional_light"):
        $DirectionalLight2D.visible = not $DirectionalLight2D.visible

    if input_event.is_action_pressed(&"cycle_point_light_shadows_quality"):
        for point_light in get_tree().get_nodes_in_group(&"point_light"):
            point_light.shadow_filter = wrapi(point_light.shadow_filter + 1, 0, 3)
```

- 使用 `wrapi()` 在 0~3 之间循环切换阴影过滤质量
- 点光源通过组（Group）批量管理

## 5. 关键概念详解

### Light2D 类型

| 类型 | 用途 | 特点 |
|------|------|------|
| `PointLight2D` | 点光源 | 从一点向四周发光，有衰减 |
| `DirectionalLight2D` | 方向光 | 模拟太阳，平行光线，无衰减 |

### 阴影过滤质量

`shadow_filter` 取值 0~3：
- 0：无过滤（最锐利，性能最好）
- 1：PCF 5x5
- 2：PCF 9x9
- 3：PCF 13x13（最柔和，性能最差）

### LightOccluder2D

遮光体节点，需要配置 `OccluderPolygon2D` 定义遮挡形状。光源遇到遮光体会产生阴影。

## 6. 场景树全景

```
LightShadows (Node2D)
├── DirectionalLight2D
├── PointLight2D ×N
├── Sprite2D ×N
│   └── LightOccluder2D
└── ...
```

## 7. 如何扩展

- 添加动态光源（跟随鼠标移动的点光源）
- 使用 `AnimationPlayer` 让光源颜色随时间变化
- 调整 `shadow_color` 属性改变阴影颜色
