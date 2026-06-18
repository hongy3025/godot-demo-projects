# Dynamic Split Screen - 源代码导读

> 本文档面向 Godot 新手，讲解如何实现动态分屏（Voronoi 分屏）效果。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

实现乐高游戏风格的动态分屏：两个玩家靠近时共享全屏，远离时屏幕沿任意角度分割。每个玩家有自己的相机和视口，通过着色器混合显示。

---

## 2. 核心架构

```
两个玩家 → 各自的位置
    ↓
CameraController 计算相机位置
    ↓
两个 SubViewport 分别渲染
    ↓
SplitScreen 着色器 → 根据玩家位置决定每个像素显示哪个视口
    ↓
TextureRect 全屏显示
```

---

## 3. 文件逐层导读

### `camera_controller.gd` — 核心控制 ⭐

**关键参数：**

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `max_separation` | 20.0 | 触发分屏的玩家距离阈值 |
| `split_line_thickness` | 3.0 | 分割线宽度（像素） |
| `split_line_color` | 黑色 | 分割线颜色 |
| `adaptive_split_line_thickness` | true | 分割线宽度是否随距离变化 |

**相机定位逻辑：**

```gdscript
# 相机放在两个玩家连线的中点上
# 靠近时 → 两个相机重合 → 显示同一画面（不分屏）
# 远离时 → 两个相机向各自玩家偏移 → 分屏
var distance := clampf(horizontal_length, 0, max_separation)
camera1.position = player1.position + direction * distance / 2
camera2.position = player2.position - direction * distance / 2
```

### `player.gd` — 玩家控制

```gdscript
func _physics_process(_delta: float) -> void:
    var move_direction := Input.get_vector(
        "move_left_player1", "move_right_player1",
        "move_up_player1", "move_down_player1")
    velocity.x += move_direction.x * walk_speed
    velocity.z += move_direction.y * walk_speed
    velocity *= 0.9  # 摩擦力
    move_and_slide()
```

玩家 1 使用 WASD，玩家 2 使用 IJKL（或方向键）。

### `split_screen.gdshader` — 分屏着色器 ⭐

```glsl
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D viewport1;
uniform sampler2D viewport2;
uniform bool split_active;
uniform vec2 player1_position;
uniform vec2 player2_position;

void fragment() {
    if (split_active) {
        // 计算分割线方向（垂直于两个玩家的连线）
        // 判断当前像素在分割线的哪一侧 → 选择对应视口
        // 在分割线位置绘制抗锯齿线条
    } else {
        COLOR = texture(viewport1, UV); // 不分屏时只显示玩家1的视口
    }
}
```

**分割线计算：** 分割线垂直于两个玩家在屏幕上的连线，通过 `distance_to_line` 函数检测像素到分割线的距离。

### `wall_coloring.gd` — 墙壁随机着色

```gdscript
func _ready() -> void:
    var walls := get_tree().get_nodes_in_group(&"walls")
    for wall in walls:
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(randf(), randf(), randf())
        wall.material_override = material
```

---

## 4. 关键概念详解

### 动态分屏原理

```
玩家靠近 (距离 < max_separation):
    两个相机位置相同 → 显示同一画面 → 不分屏

玩家远离 (距离 > max_separation):
    两个相机向各自玩家偏移 → 画面不同
    分割线 = 垂直于玩家连线的直线
    每个像素判断在分割线哪一侧 → 选择对应视口
```
