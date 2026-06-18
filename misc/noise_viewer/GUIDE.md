# 噪声查看器 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用 FastNoiseLite 生成和调整程序化噪声纹理"。

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

这是一个 **Godot 4.6** 的噪声查看器项目。核心功能是：

> **通过 GUI 控件实时调整 FastNoiseLite 纹理的各种参数，直观地观察参数变化对噪声效果的影响。**

可调参数：
- 种子（Seed）
- 频率（Frequency）
- 分形八度（Fractal Octaves）
- 分形增益（Fractal Gain）
- 分形 Lacunarity
- 最小/最大裁剪值

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `noise_viewer.tscn`。

### 2.2 操作说明

| 控件 | 功能 |
|------|------|
| Seed SpinBox | 调整噪声种子（可随机生成） |
| Frequency SpinBox | 调整噪声频率 |
| Fractal Octaves SpinBox | 调整分形八度数量 |
| Fractal Gain SpinBox | 调整分形增益 |
| Fractal Lacunarity SpinBox | 调整分形 Lacunarity |
| Min/Max Clip SpinBox | 调整裁剪范围 |
| Random Seed Button | 随机生成种子值 |
| Documentation Button | 打开 FastNoiseLite 文档 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│           UI 控制层                   │
│  参数 SpinBox / 按钮                 │
├──────────────────────────────────────┤
│          噪声数据层                  │
│  FastNoiseLite (噪声生成器)          │
├──────────────────────────────────────┤
│          渲染层                      │
│  ShaderMaterial (裁剪着色器)         │
│  NoiseTexture2D (无缝噪声纹理)       │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `noise_viewer.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，连接 UI 控件与 FastNoiseLite 参数。

**关键变量：**

| 变量 | 类型 | 说明 |
|------|------|------|
| `noise` | `FastNoiseLite` | 噪声生成器对象 |
| `min_noise` | `float` | 最小裁剪值（-1.0~1.0） |
| `max_noise` | `float` | 最大裁剪值（-1.0~1.0） |

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化 UI 控件值为噪声当前参数 |
| `_refresh_shader_params()` | 更新着色器参数，应用裁剪范围 |

**参数同步：**

```gdscript
func _ready() -> void:
    $ParameterContainer/SeedSpinBox.value = noise.seed
    $ParameterContainer/FrequencySpinBox.value = noise.frequency
    # ...
```

所有 SpinBox 的 `value_changed` 信号连接到对应的噪声参数设置方法：

```gdscript
func _on_seed_spin_box_value_changed(value: float) -> void:
    noise.seed = int(value)

func _on_frequency_spin_box_value_changed(value: float) -> void:
    noise.frequency = value
```

**裁剪值传递到着色器：**

```gdscript
func _refresh_shader_params() -> void:
    var _min := (min_noise + 1) / 2    # -1~1 → 0~1
    var _max := (max_noise + 1) / 2
    var _material: ShaderMaterial = $SeamlessNoiseTexture.material
    _material.set_shader_parameter(&"min_value", _min)
    _material.set_shader_parameter(&"max_value", _max)
```

### 4.2 `noise_viewer.gdshader` — 裁剪着色器

**地位：** 控制噪声纹理的视觉效果，将低于/高于裁剪值的区域显示为纯色。

```glsl
shader_type canvas_item;

uniform float min_value = -1;
uniform float max_value = 1;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float gray = color.x;
    if (gray < min_value) {
        color = vec4(0, 0, 0, 1);       // 低于最小值 → 黑色
    } else if (gray > max_value) {
        color = vec4(1, 1, 1, 1);       // 高于最大值 → 白色
    }
    COLOR = color;
}
```

> **新手提示：** 噪声纹理的每个像素是灰度值（0~1），着色器根据 `min_value` 和 `max_value` 将超出范围的部分显示为纯黑或纯白。

### 4.3 `noise_viewer_material.tres` — 材质资源

包含 `FastNoiseLite` 噪声生成器和 `ShaderMaterial` 的组合。噪声纹理使用 `NoiseTexture2D` 并启用了无缝（seamless）模式。

---

## 5. 关键概念详解

### 5.1 FastNoiseLite 参数

| 参数 | 说明 |
|------|------|
| **Seed** | 随机种子，相同种子产生相同噪声 |
| **Frequency** | 频率，值越大噪声变化越密集 |
| **Fractal Octaves** | 分形八度，叠加的噪声层数，越多细节越丰富 |
| **Fractal Gain** | 分形增益，每层噪声的幅度衰减 |
| **Fractal Lacunarity** | 分形 Lacunarity，每层噪声的频率增加 |

### 5.2 裁剪范围

噪声值通常在 -1~1 范围。裁剪功能允许：
- 只显示特定范围内的噪声值
- 低于 `min_noise` 的显示为黑色
- 高于 `max_noise` 的显示为白色

### 5.3 无缝纹理

`NoiseTexture2D` 的 `seamless` 属性使纹理在平铺时没有接缝，适合用于地形生成等场景。

---

## 6. 场景树全景

### 6.1 主场景 `noise_viewer.tscn`

```
NoiseViewer (Control)
├── SeamlessNoiseTexture (TextureRect)  ← 噪声纹理显示
│   └── material = ShaderMaterial       ← 裁剪着色器
├── ParameterContainer (VBoxContainer)
│   ├── SeedSpinBox (SpinBox)
│   ├── FrequencySpinBox (SpinBox)
│   ├── FractalOctavesSpinBox (SpinBox)
│   ├── FractalGainSpinBox (SpinBox)
│   ├── FractalLacunaritySpinBox (SpinBox)
│   ├── MinClipSpinBox (SpinBox)
│   └── MaxClipSpinBox (SpinBox)
├── RandomSeed (Button)
└── Documentation (Button)
```

---

## 7. 如何扩展

### 7.1 添加更多噪声参数

FastNoiseLite 还支持更多参数，如噪声类型、分形类型等：

```gdscript
func _on_noise_type_item_selected(index: int) -> void:
    noise.noise_type = index as FastNoiseLite.NoiseType
```

### 7.2 支持彩色噪声

修改着色器，将灰度值映射为彩色：

```glsl
vec3 color_map(float gray) {
    return vec3(gray, 0.0, 1.0 - gray);  // 蓝→紫→红
}
```

### 7.3 导出噪声为图片

添加保存按钮，将当前噪声纹理导出为 PNG 文件。

---

## 推荐阅读路径

1. **`noise_viewer.gd`** — 理解噪声参数控制的逻辑
2. **`noise_viewer.gdshader`** — 理解裁剪着色器的工作原理
3. **`noise_viewer_material.tres`** — 查看材质和噪声配置
