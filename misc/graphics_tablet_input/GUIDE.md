# 绘图板输入 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用绘图板的压力感应、倾斜和笔反转功能"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的绘图板输入演示项目。核心功能是：

> **利用 `InputEventMouseMotion` 的 `pressure`、`tilt` 和 `pen_inverted` 属性，实现压力感应绘图、倾斜向量显示和橡皮擦检测。**

项目使用 `Line2D` 节点绘制线条，支持：
- 压力感应（压力越大线条越粗）
- 倾斜向量可视化
- 笔反转检测（橡皮擦）
- 输入累积开关
- V-Sync 开关
- 2D MSAA 抗锯齿

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `graphics_tablet_input.tscn`。

### 2.2 操作说明

| 按键 | 功能 |
|------|------|
| Ctrl+Z | 撤销上一笔 |
| Ctrl+Shift+Z | 清除所有线条 |
| C | 切换线条颜色 |
| + | 增加线条宽度 |
| - | 减小线条宽度 |
| P | 切换压力感应 |
| T | 切换倾斜向量显示 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────────┐
│              UI 控制层                    │
│  颜色选择 / 宽度滑块 / 压力开关 / MSAA   │
├──────────────────────────────────────────┤
│              绘图引擎层                   │
│  Line2D 节点管理 / 压力曲线计算           │
├──────────────────────────────────────────┤
│              输入事件层                   │
│  InputEventMouseMotion (pressure/tilt)   │
│  Input.use_accumulated_input             │
└──────────────────────────────────────────┘
```

### 3.2 核心数据流

```
绘图板硬件事件
    ↓
InputEventMouseMotion
  ├── .position → 线条坐标
  ├── .pressure → 压力值 (0.0~1.0)
  ├── .tilt     → 倾斜向量
  └── .pen_inverted → 是否使用橡皮擦
    ↓
_input() 处理
  ├── 添加点到当前 Line2D
  ├── 记录压力值到 pressures 数组
  └── 更新宽度曲线 (Curve)
    ↓
每 1024 点自动分割新线条（性能优化）
```

---

## 4. 文件逐层导读

### 4.1 `graphics_tablet_input.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，处理所有绘图逻辑和 UI 交互。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `SPLIT_POINT_COUNT` | 1024 | 线条超过此点数时自动分割，避免性能问题 |

**关键变量：**

| 变量 | 类型 | 说明 |
|------|------|------|
| `stroke` | `Line2D` | 当前正在绘制的线条 |
| `width_curve` | `Curve` | 压力宽度曲线 |
| `pressures` | `PackedFloat32Array` | 记录每个点的压力值 |
| `pressure_sensitive` | `bool` | 是否启用压力感应 |
| `show_tilt_vector` | `bool` | 是否显示倾斜向量 |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 禁用输入累积，启动第一条线条 |
| `_input(event)` | 处理所有输入事件（鼠标/绘图板移动、按键） |
| `start_stroke()` | 创建新的 `Line2D` 节点并添加到场景 |
| `_draw()` | 绘制倾斜向量指示线 |

**压力感应逻辑（`_input` 中）：**

```gdscript
if event_mouse_motion.pressure > 0:
    stroke.add_point(event_mouse_motion.position)
    pressures.push_back(event_mouse_motion.pressure)
    if width_curve:
        width_curve.clear_points()
        for pressure_idx in range(pressures.size()):
            width_curve.add_point(Vector2(
                    float(pressure_idx) / pressures.size(),
                    pressures[pressure_idx]
                ))
```

> **新手提示：** `width_curve` 将每个点的压力值映射到 0~1 区间，`Line2D` 根据曲线自动调整每个点的宽度。

**输入累积说明：**

```gdscript
Input.use_accumulated_input = false  # 禁用累积，获取最高精度输入
```

禁用输入累积后，引擎会以操作系统报告的频率接收输入事件，不受帧率限制。代价是更高的 CPU 使用率。

### 4.2 撤销与清除

**撤销逻辑（`_on_undo_last_line_pressed`）：**

```gdscript
var last_line_2d := find_children("", "Line2D")[-1]
if last_line_2d.get_point_count() == 0:
    last_line_2d.queue_free()  # 移除空线条
    var other_last_line_2d := find_children("", "Line2D")[-2]
    other_last_line_2d.queue_free()  # 再移除一条
else:
    last_line_2d.queue_free()
```

由于鼠标移动时会自动创建新线条（即使没有按下），撤销时需要处理空线条的情况。

---

## 5. 关键概念详解

### 5.1 压力感应如何工作

1. 绘图板报告每个点的压力值（0.0~1.0）
2. 压力值存储在 `pressures` 数组中
3. 每次添加新点时重建 `width_curve`，将压力映射到曲线
4. `Line2D` 使用 `width_curve` 自动调整每个点的宽度

### 5.2 线条分割策略

每 1024 个点自动创建新线条，原因：
- `Line2D` 的宽度曲线在每次添加新点时都需要重建
- 过长的线条会导致性能问题
- 分割后每个线条独立管理，性能更优

### 5.3 倾斜向量

`event.tilt` 返回一个 `Vector2`，表示笔的倾斜方向和角度。项目在 `_draw()` 中绘制一条从鼠标位置到 `position + tilt * 50` 的红线来可视化。

### 5.4 低处理器模式

项目启用了 `run/low_processor_mode=true`，通过调整 `OS.low_processor_usage_mode_sleep_usec` 来控制最大 FPS，而不是使用 V-Sync。

---

## 6. 场景树全景

### 6.1 主场景 `graphics_tablet_input.tscn`

```
GraphicsTabletInput (Control)
├── CanvasLayer
│   └── PanelContainer (Options 面板)
│       ├── LineColor (ColorPickerButton)
│       ├── LineWidth (HSlider + Value)
│       ├── PressureSensitive (CheckButton)
│       ├── ShowTiltVector (CheckButton)
│       ├── MSAA (OptionButton)
│       ├── MaxFPS (HSlider + Value)
│       ├── V-Sync (CheckButton)
│       ├── InputAccumulation (CheckButton)
│       ├── UndoLastLine (Button)
│       └── ClearAllLines (Button)
├── TabletInfo (Label)                  ← 显示压力/倾斜/笔反转信息
└── TabletDriver (Label)                ← 显示当前绘图板驱动
```

运行时动态添加 `Line2D` 子节点用于绘图。

---

## 7. 如何扩展

### 7.1 添加颜色预设

在 `_on_line_color_changed()` 中添加更多颜色选项：

```gdscript
var colors := [Color.BLACK, Color.RED, Color.BLUE, Color.GREEN]
```

### 7.2 实现橡皮擦功能

检测 `pen_inverted` 属性，切换为擦除模式：

```gdscript
if event_mouse_motion.pen_inverted:
    # 擦除模式：移除经过的线条
    stroke.default_color = Color.TRANSPARENT
```

### 7.3 保存/加载画布

将场景中所有 `Line2D` 的点序列化到文件，实现保存功能。

---

## 推荐阅读路径

1. **`graphics_tablet_input.gd`** — 理解绘图板输入的核心处理逻辑
2. **`project.godot`** — 查看输入映射和渲染设置
