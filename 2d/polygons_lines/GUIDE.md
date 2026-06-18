# 2D Polygons and Lines - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示 `Polygon2D` 和 `Line2D` 节点的使用，以及 2D 抗锯齿的两种实现方式：纹理抗锯齿和 MSAA。

## 2. 快速上手

运行 `polygons_lines.tscn`，在下拉菜单中切换 MSAA 级别，观察抗锯齿效果变化。

## 3. 核心架构

```
polygons_lines.tscn
├── PolygonsLines (Node2D)
│   ├── TabContainer
│   │   ├── SolidPolygons    ← 实心多边形
│   │   ├── TexturedPolygons ← 纹理多边形
│   │   ├── Lines            ← 线条
│   │   └── Antialiasing     ← 抗锯齿演示
│   ├── MSAA (OptionButton)  ← MSAA 选择
│   └── UnsupportedLabel     ← 兼容性提示
```

## 4. 文件逐层导读

### `polygons_lines.gd` — 主控

```gdscript
func _ready():
    if RenderingServer.get_current_rendering_method() == "gl_compatibility":
        $MSAA.visible = false
        $UnsupportedLabel.visible = true

func _on_msaa_option_button_item_selected(index):
    get_viewport().msaa_2d = index as Viewport.MSAA
```

## 5. 关键概念详解

### Line2D 抗锯齿

Line2D 使用一种特殊纹理实现抗锯齿：纹理上下边缘为透明，中间为白色。利用双线性过滤使线条边缘平滑。

### MSAA 2D

视口级别的多重采样抗锯齿，适用于所有 2D 绘制（包括 `Polygon2D` 和自定义绘制）。仅 Forward+ 和 Mobile 渲染器支持。

### Polygon2D

- `polygon`：顶点数组
- `uv`：纹理坐标
- `texture`：填充纹理
- `color`：顶点颜色

## 6. 场景树全景

```
PolygonsLines (Node2D)
├── SolidPolygons (Control)
│   └── Polygon2D ×N
├── TexturedPolygons (Control)
│   └── Polygon2D ×N
├── Lines (Control)
│   └── Line2D ×N
├── Antialiasing (Control)
│   ├── Line2D (texture AA)
│   └── Polygon2D (MSAA)
├── MSAA (OptionButton)
└── UnsupportedLabel
```

## 7. 如何扩展

- 使用 `Polygon2D` 的 `bones` 和 `weights` 实现骨骼动画
- 用 `Line2D` 的 `points` 动态绘制曲线
- 结合 `ShaderMaterial` 实现多边形着色器效果
