# Audio Spectrum Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中构建频谱分析器"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的音频频谱分析技术演示项目。核心思路是：

> **使用 `AudioEffectSpectrumAnalyzerInstance` 获取音频频谱数据，通过 `_draw()` 方法实时绘制 16 条频率柱状图。**

项目演示了：
- 频谱分析器的数据获取
- 自定义 `_draw()` 绘制柱状图
- 带平滑动画的频谱显示
- 镜像反射效果

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `show_spectrum.tscn`。

背景音乐自动播放，频谱柱状图实时跳动显示。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│          绘制层 (Node2D._draw())            │
│  16 条频率柱 + 镜像反射                     │
├─────────────────────────────────────────────┤
│        频谱数据层 (show_spectrum.gd)        │
│  AudioEffectSpectrumAnalyzerInstance        │
├─────────────────────────────────────────────┤
│       音频总线层 (Master 总线)              │
│  AudioEffectSpectrumAnalyzer 效果           │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `show_spectrum.gd` — 主控制脚本 ⭐

**继承自 `Node2D`**，包含全部核心逻辑。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `VU_COUNT` | 16 | 频率条数量 |
| `FREQ_MAX` | 11050.0 | 最大频率（Hz） |
| `WIDTH` | 800 | 绘制区域宽度 |
| `HEIGHT` | 250 | 绘制区域高度 |
| `HEIGHT_SCALE` | 8.0 | 高度缩放系数 |
| `MIN_DB` | 60 | 最小分贝值 |
| `ANIMATION_SPEED` | 0.1 | 动画平滑速度 |

#### `_ready()` — 初始化

```gdscript
spectrum = AudioServer.get_bus_effect_instance(0, 0)
```

获取 Master 总线（索引 0）上的第一个效果（索引 0）的频谱分析器实例。

#### `_process(_delta)` — 每帧更新频谱数据

```gdscript
for i in range(1, VU_COUNT + 1):
    var hz := i * FREQ_MAX / VU_COUNT
    var magnitude := spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
    var energy := clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
    var height := energy * HEIGHT * HEIGHT_SCALE
    data.append(height)
    prev_hz = hz
```

**逐行解析：**
1. 将 0~11050 Hz 均分为 16 个频段
2. 调用 `get_magnitude_for_frequency_range()` 获取每个频段的能量
3. 将能量值转换为分贝并归一化到 0~1
4. 乘以高度系数得到像素高度

#### 平滑动画

```gdscript
for i in VU_COUNT:
    if data[i] > max_values[i]:
        max_values[i] = data[i]
    else:
        max_values[i] = lerpf(max_values[i], data[i], ANIMATION_SPEED)
```

使用 `lerpf()` 实现平滑衰减，上升立即响应，下降缓慢过渡。

#### `_draw()` — 绘制频谱柱状图

```gdscript
draw_rect(Rect2(w * i, HEIGHT - height, w - 2, height),
    Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6))
draw_line(Vector2(w * i, HEIGHT - height), ...)
```

- 使用 HSV 颜色模型，每根柱子颜色渐变
- 绘制柱状图和顶部高光线
- 绘制下半部分的镜像反射（透明度 12.5%）

---

## 5. 关键概念详解

### 5.1 `AudioEffectSpectrumAnalyzer`

这是一种音频总线效果，分析经过总线的音频信号的频率分布。需要在总线布局中预先添加到 Master 总线。

### 5.2 `get_magnitude_for_frequency_range()`

```gdscript
spectrum.get_magnitude_for_frequency_range(from_hz, to_hz)
```

返回指定频率范围内的能量向量 `Vector2`，其中 `x` 和 `y` 分别代表左右声道的能量。

### 5.3 分贝转换

```gdscript
energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
```

- `linear_to_db()` 将线性幅度转换为分贝值
- 分贝值范围从 `-MIN_DB` 到 0，归一化到 0~1

### 5.4 场景结构

```
ShowSpectrum (Node2D)
├── AudioStreamPlayer       ← 播放背景音乐
└── (频谱通过 _draw() 绘制)
```
