# GD Paint - 源代码导读

> 本文档面向 Godot 新手，剖析用 Godot 和 GDScript 实现的简易图像编辑器。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**GD Paint**（Godot 4.6）

一个简单的图像编辑器，支持：
- **画笔模式**：铅笔、橡皮擦、矩形形状、圆形形状
- **画笔形状**：矩形笔尖、圆形笔尖
- **可调大小**、**颜色选择**、**撤销**、**保存**

---

## 2. 快速上手

运行 `paint_root.tscn`。选择工具后在画布上拖拽绘画。

---

## 3. 核心架构

```
paint_root.tscn
├── PaintControl (Control)  ← 画布，处理绘制逻辑
│   └── paint_control.gd
├── ToolsPanel (Panel)      ← 工具栏 UI
│   └── tools_panel.gd
└── DrawingAreaBG (Panel)   ← 画布背景
```

---

## 4. 文件逐层导读

### `paint_control.gd` — 核心绘制引擎 ⭐

**枚举定义：**
```gdscript
enum BrushMode { PENCIL, ERASER, CIRCLE_SHAPE, RECTANGLE_SHAPE }
enum BrushShape { RECTANGLE, CIRCLE }
```

**数据结构：** 每个笔触是一个 Dictionary：
```gdscript
new_brush.brush_type       # BrushMode
new_brush.brush_pos        # Vector2 位置
new_brush.brush_shape      # BrushShape
new_brush.brush_size       # int 大小
new_brush.brush_color      # Color
# 矩形额外字段：
new_brush.brush_shape_rect_pos_BR  # 右下角
# 圆形额外字段：
new_brush.brush_shape_circle_radius  # 半径
```

**`_process(delta)` 绘制循环：**
1. 检测鼠标是否在画布内
2. 左键按下时，铅笔/橡皮擦模式每帧添加笔触
3. 松开时，矩形/圆形模式添加形状
4. 首次按下记录 `mouse_click_start_pos`

**`check_if_mouse_is_inside_canvas()`：**
- 确保点击起始位置在画布内（防止从外部拖入）
- 确保当前鼠标位置在画布内

**`undo_stroke()` 撤销：**
- 铅笔/橡皮擦：根据 `undo_element_list_num` 删除最近一次笔画的所有笔触
- 形状模式：直接删除最后一个形状

**`_draw()` 渲染：**
```gdscript
match brush.brush_type:
    BrushMode.PENCIL:
        draw_rect(rect, brush.brush_color)  # 矩形笔尖
        draw_circle(..., brush_size / 2)    # 圆形笔尖
    BrushMode.ERASER:
        # 用背景色"覆盖"实现擦除
        draw_rect(rect, bg_color)
    BrushMode.RECTANGLE_SHAPE:
        draw_rect(Rect2(TL, BR - TL), brush_color)
    BrushMode.CIRCLE_SHAPE:
        draw_circle(center, radius, brush_color)
```

**`save_picture(path)` 保存：**
1. `await RenderingServer.frame_post_draw` 等待帧完成
2. `get_viewport().get_texture().get_image()` 截取视口
3. `get_region()` 裁剪画布区域
4. 按扩展名保存 PNG / WebP / JPEG

### `tools_panel.gd` — 工具栏逻辑

**信号连接：** 在 `_ready()` 中连接所有按钮信号。

**`button_pressed(button_name)` 分发：**
- 模式按钮 → 修改 `paint_control.brush_mode`
- 形状按钮 → 修改 `paint_control.brush_shape`
- 操作按钮 → 清空/保存/撤销

**`_physics_process()`：** 实时更新笔触数量统计。

---

## 5. 关键概念详解

### 5.1 擦除原理

橡皮擦不是真正擦除像素，而是用背景色覆盖绘制。这意味着：
- 改变背景色后需 `queue_redraw()` 重绘
- 无法恢复被擦除的像素（除非撤销）

### 5.2 形状绘制

矩形和圆形在鼠标**松开时**才生成，而铅笔/橡皮擦在**拖拽过程中**持续绘制。

### 5.3 撤销机制

- `undo_element_list_num` 记录每次新笔画开始前的笔触总数
- 撤销时删除从该位置到末尾的所有笔触
- 形状模式用 `UNDO_MODE_SHAPE = -2` 特殊标记
