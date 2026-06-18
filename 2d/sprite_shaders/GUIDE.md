# 2D Shaders for Sprites - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示多种应用于精灵（Sprite2D）的着色器效果，包括轮廓、模糊、扭曲、阴影、辉光、溶解、光环等。所有效果通过 `ShaderMaterial` 实现。

## 2. 快速上手

运行 `sprite_shaders.tscn`，浏览不同着色器效果在精灵上的表现。

## 3. 核心架构

```
sprite_shaders.tscn
└── SpriteShaders (Node2D)
    ├── Sprite2D (Original)     ← 原始精灵（无效果）
    ├── Sprite2D (Outline)      ← 轮廓
    ├── Sprite2D (Blur)         ← 模糊
    ├── Sprite2D (Glow)         ← 辉光
    ├── Sprite2D (DropShadow)   ← 投影
    ├── Sprite2D (OffsetShadow) ← 偏移阴影
    ├── Sprite2D (Silhouette)   ← 剪影
    ├── Sprite2D (Fatty)        ← 膨胀
    ├── Sprite2D (Dissintegrate) ← 溶解
    └── Sprite2D (Aura)         ← 光环
```

**注意：** 本项目没有 `.gd` 脚本文件，所有效果通过 `ShaderMaterial` 直接在精灵上配置。

## 4. 着色器文件导读

### `shaders/*.gdshader`

| 文件 | 效果 | 原理 |
|------|------|------|
| `outline.gdshader` | 轮廓描边 | 采样周围像素，检测透明度边缘 |
| `blur.gdshader` | 高斯模糊 | 水平和垂直方向多次采样加权 |
| `glow.gdshader` | 辉光 | 提取亮部，模糊后叠加 |
| `dropshadow.gdshader` | 投影 | 偏移并模糊副本 |
| `offsetshadow.gdshader` | 偏移阴影 | 平移副本，半透明 |
| `silouette.gdshader` | 剪影 | 统一颜色，保留透明度 |
| `fatty.gdshader` | 膨胀 | UV 向中心收缩 |
| `dissintegrate.gdshader` | 溶解 | 使用噪点纹理，逐像素消失 |
| `aura.gdshader` | 光环 | 从边缘向外扩散的发光 |

## 5. 关键概念详解

### ShaderMaterial

`ShaderMaterial` 允许为每个精灵编写自定义着色器。着色器类型为 `canvas_item`，作用于 2D 画布项。

### 轮廓着色器原理

```glsl
// 简化版：检测 alpha 边缘
vec4 color = texture(TEXTURE, UV);
float alpha = color.a;
// 采样四周像素
float edge = max(max(
    texture(TEXTURE, UV + vec2(thickness, 0)).a,
    texture(TEXTURE, UV - vec2(thickness, 0)).a),
    max(
    texture(TEXTURE, UV + vec2(0, thickness)).a,
    texture(TEXTURE, UV - vec2(0, thickness)).a));
// 如果当前像素透明但周围有不透明 → 边缘
if (alpha < 0.5 && edge > 0.5) COLOR = outline_color;
```

## 6. 场景树全景

```
SpriteShaders (Node2D)
├── Sprite2D (Original)
├── Sprite2D (Outline) → ShaderMaterial(outline.gdshader)
├── Sprite2D (Blur) → ShaderMaterial(blur.gdshader)
├── Sprite2D (Glow) → ShaderMaterial(glow.gdshader)
├── Sprite2D (DropShadow) → ShaderMaterial(dropshadow.gdshader)
├── Sprite2D (OffsetShadow) → ShaderMaterial(offsetshadow.gdshader)
├── Sprite2D (Silhouette) → ShaderMaterial(silouette.gdshader)
├── Sprite2D (Fatty) → ShaderMaterial(fatty.gdshader)
├── Sprite2D (Dissintegrate) → ShaderMaterial(dissintegrate.gdshader)
└── Sprite2D (Aura) → ShaderMaterial(aura.gdshader)
```

## 7. 如何扩展

- 复制现有着色器文件，修改参数创建新效果
- 为着色器添加 `uniform` 变量，在 Inspector 中调整参数
- 结合 `AnimationPlayer` 动态改变着色器参数（如溶解进度）
