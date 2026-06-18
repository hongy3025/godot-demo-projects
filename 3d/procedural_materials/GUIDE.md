# 程序化材质 - 源代码导读

> 本文档面向 Godot 新手，剖析程序化材质演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Procedural Materials**（`project.godot` 中 `config/name`）

展示三种程序化材质生成技术：NoiseTexture2D、脚本生成（Image 类）、着色器生成（ViewportTexture）。

主场景：`loading.tscn` → `material_tester.tscn`

## 2. 快速上手

运行后等待材质生成完成，左右箭头键切换不同的程序化材质示例。

## 3. 核心架构

```
procedural_materials/
├── loading.tscn              ← 加载场景
├── material_tester.tscn      ← 主场景
├── tester.gd                 ← 主控脚本
├── loading.gd                ← 加载逻辑
└── scripts/
    └── grid.gd               ← 网格布局
```

## 4. 文件逐层导读

### 三种程序化技术

#### 1. NoiseTexture2D（内置类）

```gdscript
# 在 CPU 上基于噪声模式生成图像
var noise_texture = NoiseTexture2D.new()
noise_texture.noise = FastNoiseLite.new()
noise_texture.width = 512
noise_texture.height = 512
```

- 适合静态纹理
- 异步生成，速度快
- 噪声算法在 C++ 中实现

#### 2. 脚本生成（Image 类）

```gdscript
var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
image.set_pixel(x, y, color)
var texture = ImageTexture.create_from_image(image)
```

- 适合静态纹理
- 比 NoiseTexture2D 更灵活
- 生成速度较慢

#### 3. 着色器生成（ViewportTexture）

```gdscript
# ColorRect 节点上的 2D 着色器 → Viewport → ViewportTexture
var viewport = Viewport.new()
var color_rect = ColorRect.new()
color_rect.material = shader_material
viewport.add_child(color_rect)
var texture = viewport.get_texture()
```

- 在 GPU 上实时更新
- 适合动画纹理
- 也可用于静态纹理（不每帧更新）

### `loading.gd` — 加载场景

在进入主场景前预生成程序化材质，避免运行时卡顿。

### `scripts/grid.gd` — 网格布局

将多个材质示例排列在网格中，方便对比观察。
