# Custom Drawing in 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 `CanvasItem` 的 `draw_*` 方法在 Godot 中自定义绘制 2D 图形，无需使用 Sprite2D、Polygon2D 等节点。适用于程序化生成图形、调试绘制和性能优化。

## 2. 快速上手

运行主场景，通过 Tab 切换不同绘制类别（线条、多边形、矩形、纹理、网格、文字、动画）。顶部可切换 MSAA 和抗锯齿开关。

## 3. 核心架构

```
custom_drawing.tscn
└── CustomDrawing (Control)     ← 根节点，管理 MSAA 和抗锯齿
    └── TabContainer            ← 分页容器
        ├── Lines              ← 线条绘制
        ├── Polygons           ← 多边形绘制
        ├── Rectangles         ← 矩形绘制
        ├── Textures           ← 纹理绘制
        ├── Meshes             ← 网格绘制
        ├── Text               ← 文字绘制
        └── Animation          ← 动画绘制
```

每个 Tab 页是一个独立的 `Control`，在 `_draw()` 中调用 `draw_*` 方法。

## 4. 文件逐层导读

### `custom_drawing.gd` — 主控制器

```gdscript
func _on_msaa_2d_item_selected(index: int) -> void:
    get_viewport().msaa_2d = index as Viewport.MSAA
```

- 控制全局 MSAA 级别（0x/2x/4x/8x）
- 控制所有 Tab 页的 `use_antialiasing` 属性

### 各绘制脚本

| 文件 | 演示内容 | 关键方法 |
|------|----------|----------|
| `lines.gd` | 直线、曲线、虚线、抗锯齿线条 | `draw_line()`, `draw_circle()` |
| `polygons.gd` | 实心多边形、空心多边形 | `draw_polygon()`, `draw_polyline()` |
| `rectangles.gd` | 矩形、圆角矩形、边框 | `draw_rect()`, `draw_string()` |
| `textures.gd` | 纹理绘制、九宫格缩放 | `draw_texture()`, `draw_texture_rect()` |
| `meshes.gd` | 自定义网格绘制 | `draw_mesh()` |
| `text.gd` | 文字绘制、字体变换 | `draw_string()`, `draw_char()` |
| `animation.gd` | 动态绘制（旋转矩形） | 在 `_process()` 中调用 `queue_redraw()` |

### `animation_slice.gd` — 动画切片

展示如何在 `_process()` 中持续更新绘制内容，实现动画效果。

## 5. 关键概念详解

### `queue_redraw()`

所有 `draw_*` 方法必须在 `_draw()` 中调用。要触发重绘，需调用 `queue_redraw()`（通常在 `_process()` 中）。

### 抗锯齿方案

| 方案 | 适用 | 性能 |
|------|------|------|
| `draw_*` 方法的 `antialiasing` 参数 | 支持该参数的绘制方法 | 较快 |
| 2D MSAA（视口级别） | 所有 2D 绘制 | 较慢，仅 Forward+/Mobile 渲染器 |

## 6. 如何扩展

- 在 `TabContainer` 中添加新的 Tab 页，继承 `Control` 并实现 `_draw()`
- 使用 `draw_set_transform()` 实现坐标变换
- 结合 `_process()` 和 `queue_redraw()` 实现实时动画
