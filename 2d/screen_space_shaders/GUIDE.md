# Screen Space Shaders - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示多种全屏 2D 着色器效果，包括漩涡、晕影、旧电影、像素化、模糊、负片、棕褐色等。所有效果通过 `ColorRect` 上的 `ShaderMaterial` 实现。

## 2. 快速上手

运行 `screen_shaders.tscn`，下拉菜单选择图片和效果。

## 3. 核心架构

```
screen_shaders.tscn
├── ScreenShaders (Control)
│   ├── Pictures (Control)   ← 图片选择
│   │   ├── Godot (TextureRect)
│   │   └── ...
│   ├── Effects (Control)    ← 效果选择
│   │   ├── Whirl (ColorRect)     ← 漩涡
│   │   ├── Vignette (ColorRect)  ← 晕影
│   │   ├── OldFilm (ColorRect)   ← 旧电影
│   │   ├── Pixelize (ColorRect)  ← 像素化
│   │   ├── Blur (ColorRect)      ← 模糊
│   │   ├── Negative (ColorRect)  ← 负片
│   │   ├── Sepia (ColorRect)     ← 棕褐色
│   │   ├── Contrasted (ColorRect) ← 对比度
│   │   ├── BCS (ColorRect)       ← 亮度/对比度/饱和度
│   │   ├── Mirage (ColorRect)    ← 海市蜃楼
│   │   └── Normalized (ColorRect) ← 法线可视化
│   ├── Picture (OptionButton)
│   └── Effect (OptionButton)
```

## 4. 文件逐层导读

### `screen_shaders.gd` — 效果切换

```gdscript
func _ready():
    for c in pictures.get_children():
        picture.add_item("PIC: " + String(c.get_name()))
    for c in effects.get_children():
        effect.add_item("FX: " + String(c.get_name()))
```

通过遍历子节点动态填充下拉菜单，选中时显示对应子节点。

### 着色器文件（`shaders/*.gdshader`）

| 文件 | 效果 | 核心算法 |
|------|------|----------|
| `whirl.gdshader` | 漩涡扭曲 | 极坐标旋转，随时间变化 |
| `vignette.gdshader` | 晕影 | 基于到中心距离的暗角 |
| `old_film.gdshader` | 旧电影 | 颜色偏移 + 噪点 + 刮痕 |
| `pixelize.gdshader` | 像素化 | 降低 UV 采样精度 |
| `blur.gdshader` | 高斯模糊 | 多方向采样加权平均 |
| `negative.gdshader` | 负片 | `1.0 - color` |
| `sepia.gdshader` | 棕褐色 | 颜色矩阵变换 |
| `contrasted.gdshader` | 对比度 | 对比度公式 |
| `BCS.gdshader` | 亮度/对比度/饱和度 | 三项参数可调 |
| `mirage.gdshader` | 海市蜃楼 | UV 扭曲 + 热浪效果 |
| `normalized.gdshader` | 法线可视化 | 调试用 |

## 5. 关键概念详解

### 全屏着色器原理

每个效果是一个 `ColorRect`，覆盖整个屏幕。其 `ShaderMaterial` 使用 `canvas_item` 着色器，通过 `UV` 坐标访问屏幕像素，修改后输出。

### 着色器结构

```glsl
shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // 处理 color
    COLOR = color;
}
```

## 6. 场景树全景

```
ScreenShaders (Control)
├── Pictures
│   ├── Godot (TextureRect)
│   └── ... (更多图片)
├── Effects
│   ├── Whirl (ColorRect) → ShaderMaterial
│   ├── Vignette (ColorRect) → ShaderMaterial
│   └── ... (更多效果)
├── Picture (OptionButton)
└── Effect (OptionButton)
```

## 7. 如何扩展

- 在 `Effects/` 下添加新的 `ColorRect`，挂载自定义着色器
- 在 `screen_shaders.gd` 中无需修改代码，新效果自动出现在菜单中
- 添加参数滑块（如模糊强度、漩涡速度）
