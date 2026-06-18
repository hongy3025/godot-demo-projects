# Multiple Resolutions and Aspect Ratios - 源代码导读

> 本文档面向 Godot 新手，剖析多分辨率与宽高比适配的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Multiple Resolutions and Aspect Ratios**（Godot 4.6）

演示如何让 GUI 适应不同分辨率和宽高比：
- 调整基础分辨率、拉伸模式、宽高比、缩放因子
- GUI 边距设置（适配电视过扫描）
- MSDF 字体确保任意分辨率下清晰

---

## 2. 快速上手

运行 `main.tscn`。调整窗口大小，使用下拉菜单切换不同设置观察效果。

---

## 3. 核心架构

```
main.tscn
└── main.gd  ← 核心控制逻辑
```

关键节点：`AspectRatioContainer` 用于约束 GUI 宽高比。

---

## 4. 文件逐层导读

### `main.gd` — 多分辨率控制 ⭐

**核心变量：**
```gdscript
var base_window_size := Vector2(...)  # 基础窗口大小
var stretch_mode := Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
var stretch_aspect := Window.CONTENT_SCALE_ASPECT_EXPAND
var scale_factor := 1.0
var gui_aspect_ratio := -1.0  # -1 表示"适应窗口"
var gui_margin := 0.0
```

**`update_container()` 核心更新逻辑：**
```gdscript
if is_equal_approx(gui_aspect_ratio, -1.0):
    arc.ratio = panel.size.aspect()  # 适应窗口
else:
    arc.ratio = min(panel.size.aspect(), gui_aspect_ratio)  # 约束宽高比
```
- 使用 `call_deferred()` 延迟一帧执行（容器更新有 1 帧延迟）
- 循环两次解决容器大小缓存问题

**宽高比选项：**

| 索引 | 比例 | 值 |
|------|------|----|
| 0 | 适应窗口 | -1.0 |
| 1 | 5:4 | 1.25 |
| 2 | 4:3 | 1.333... |
| 3 | 3:2 | 1.5 |
| 4 | 16:10 | 1.6 |
| 5 | 16:9 | 1.777... |
| 6 | 21:9 | 2.333... |

**窗口设置回调：**
- `_on_window_base_size_item_selected` — 切换基础分辨率
- `_on_window_stretch_mode_item_selected` — 切换拉伸模式
- `_on_window_stretch_aspect_item_selected` — 切换拉伸宽高比
- `_on_window_scale_factor_drag_ended` — 调整缩放因子

**设置方式：** 通过 `get_window().content_scale_*` 属性在运行时修改。

---

## 5. 关键概念详解

### 5.1 拉伸模式

| 模式 | 效果 |
|------|------|
| `CONTENT_SCALE_MODE_DISABLED` | 不拉伸，像素精确 |
| `CONTENT_SCALE_MODE_CANVAS_ITEMS` | 缩放画布项（推荐 2D 游戏） |
| `CONTENT_SCALE_MODE_VIEWPORT` | 缩放视口（像素艺术游戏） |

### 5.2 AspectRatioContainer

- `ratio` 属性控制宽高比约束
- 设为 `panel.size.aspect()` 时无约束效果
- 设为固定值（如 16/9）时约束子控件宽高比

### 5.3 GUI 边距

- 通过 `panel.offset_*` 设置边距
- 适应宽高比时边距自动调整
- 解决电视过扫描和超大屏幕 HUD 分散问题

### 5.4 项目设置要点

- `canvas_items` 拉伸模式
- `expand` 拉伸宽高比
- 基础窗口 648×648（1:1），窗口覆盖 1152×648（16:9）
- MSDF 字体启用：`theme/default_font_multichannel_signed_distance_field=true`
