# Compute Shader Heightmap - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用计算着色器（Compute Shader）在 GPU 上生成高度图"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的计算着色器技术演示项目。核心思路是：

> **使用 GLSL 编写的计算着色器在 GPU 上并行处理噪声纹理，生成岛屿高度图，并与 CPU 实现进行性能对比。**

项目支持两种生成方式：
| 方式 | 位置 | 特点 |
|------|------|------|
| **GPU 计算着色器** | `compute_shader.glsl` | 大规模并行，大纹理更快 |
| **CPU GDScript** | `main.gd:compute_island_cpu()` | 小纹理更快 |

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

点击"Create on GPU"或"Create on CPU"生成高度图，对比生成时间。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│              UI 层 (Control)                │
│  种子输入 / 生成按钮 / 纹理显示             │
├─────────────────────────────────────────────┤
│          CPU 生成层 (main.gd)               │
│  compute_island_cpu() → GDScript 循环       │
├─────────────────────────────────────────────┤
│          GPU 生成层 (main.gd)               │
│  RenderingDevice → compute shader           │
├─────────────────────────────────────────────┤
│       计算着色器 (compute_shader.glsl)      │
│  GLSL #version 460 → 8x8 工作组             │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `main.gd` — 主控制脚本 ⭐

**继承自 `Control`**，包含 CPU/GPU 两种实现。

#### GPU 初始化 `init_gpu()`

```gdscript
rd = RenderingServer.create_local_rendering_device()
shader_rid = load_shader(rd, shader_file)
```

创建本地渲染设备，加载并编译着色器。

#### 纹理格式设置

```gdscript
var heightmap_format := RDTextureFormat.new()
heightmap_format.format = RenderingDevice.DATA_FORMAT_R8_UNORM
heightmap_format.width = po2_dimensions
heightmap_format.height = po2_dimensions
heightmap_format.usage_bits = \
    RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
    RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
    RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
```

关键：`R8_UNORM` 表示每个像素 1 字节（红色通道），与噪声纹理的亮度通道兼容。

#### GPU 计算 `compute_island_gpu()`

```gdscript
rd.texture_update(heightmap_rid, 0, heightmap.get_data())
var compute_list := rd.compute_list_begin()
rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
rd.compute_list_dispatch(compute_list, po2_dimensions / 8, po2_dimensions / 8, 1)
rd.compute_list_end()
rd.submit()
rd.sync()
```

1. 将噪声数据上传到 GPU 纹理
2. 调度计算着色器（每 8x8 像素一个工作组）
3. 等待 GPU 完成
4. 读取结果数据

#### CPU 计算 `compute_island_cpu()`

```gdscript
for y in range(0, po2_dimensions):
    for x in range(0, po2_dimensions):
        var pixel := heightmap.get_pixelv(coord)
        var distance := Vector2(center).distance_to(Vector2(coord))
        var gradient_color := gradient.sample(distance / float(center.x))
        pixel.v *= gradient_color.v
        if pixel.v < 0.2:
            pixel.v = 0.0
        heightmap.set_pixelv(coord, pixel)
```

双层循环遍历每个像素，与 GPU 着色器逻辑完全对应。

### `compute_shader.glsl` — 计算着色器 ⭐

```glsl
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(r8, binding = 0) restrict uniform image2D heightmap;
layout(rgba8, binding = 1) restrict readonly uniform image2D gradient;

void main() {
    ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
    ivec2 center = dimensions / 2;
    float dist = distance(coords, center);
    int gradient_x = int(mix(0.0, float(gradient_max_x), dist / float(smallest_radius)));
    vec4 gradient_color = imageLoad(gradient, ivec2(gradient_x, 0));
    vec4 pixel = imageLoad(heightmap, coords);
    pixel.r *= gradient_color.r;
    pixel.r = step(0.2, pixel.r) * pixel.r;
    imageStore(heightmap, coords, pixel);
}
```

**逐行解析：**
1. `gl_GlobalInvocationID` — 每个线程的全局 ID，对应像素坐标
2. 计算像素到中心的距离
3. 根据距离采样渐变纹理
4. 将像素值乘以渐变值（边缘淡出）
5. `step(0.2, pixel.r) * pixel.r` — 低于阈值设为 0（形成海岸线）

---

## 5. 关键概念详解

### 5.1 计算着色器工作流程

```
1. 创建 RenderingDevice
2. 编译 GLSL 着色器 → 创建 Pipeline
3. 创建纹理并上传数据
4. 创建 Uniform Set（绑定纹理到着色器）
5. 调度计算 (dispatch)
6. 同步等待
7. 读取结果
```

### 5.2 工作组 (Workgroup) 概念

```
纹理 2048×2048
工作组大小 8×8
调度数量 = 2048/8 × 2048/8 = 256 × 256 = 65536 个工作组
每个工作组 64 个线程，总共 4,194,304 个线程并行运行
```

### 5.3 场景结构

```
Main (Control)
├── SeedInput (SpinBox)
├── RandomButton
├── CreateButtonGPU (Button)
├── CreateButtonCPU (Button)
├── RawHeightmap (TextureRect)
├── ComputedHeightmap (TextureRect)
└── TimeLabel (Label)
```
