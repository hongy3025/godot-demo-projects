# Compute Texture - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用计算着色器生成纹理并驱动材质着色器"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的计算纹理技术演示项目（需要 Forward+ 渲染器）。核心思路是：

> **使用计算着色器在 GPU 上模拟水波纹物理，将高度数据写入纹理，通过 `Texture2DRD` 传递给材质着色器实现 3D 水面效果。**

项目实现了经典的水波纹算法（90 年代技术，适配为计算着色器）：
- 鼠标悬停时可在水面绘制波纹
- 鼠标离开时自动随机产生雨滴
- 支持旋转视角

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

鼠标在水面上移动产生波纹，点击左键产生更大波纹。按旋转按钮可旋转视角。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│         场景控制层 (main.gd)                │
│  UI 控制 / 旋转 / 参数传递                 │
├─────────────────────────────────────────────┤
│        水波逻辑层 (water_plane.gd)         │
│  计算着色器调度 / 鼠标交互 / 纹理循环      │
├─────────────────────────────────────────────┤
│       计算着色器 (water_compute.glsl)       │
│  经典波纹算法 / 8×8 工作组                  │
├─────────────────────────────────────────────┤
│       材质着色器 (water_shader.gdshader)    │
│  高度图 → 法线计算 → 水面渲染              │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `water_plane.gd` — 核心逻辑 ⭐

**继承自 `Area3D`**，包含计算着色器的完整生命周期。

#### 三纹理循环机制

```gdscript
var texture_rds: Array[RID] = [RID(), RID(), RID()]
```

使用 3 个纹理实现波纹传播：
| 索引 | 含义 |
|------|------|
| `current` | 当前帧数据（读取） |
| `previous` | 上一帧数据（读取） |
| `next` | 下一帧数据（写入） |

每帧循环：`next_texture = (next_texture + 1) % 3`

#### `_initialize_compute_code()` — GPU 初始化

```gdscript
tf.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
tf.usage_bits = TEXTURE_USAGE_SAMPLING_BIT | TEXTURE_USAGE_STORAGE_BIT | TEXTURE_USAGE_CAN_COPY_TO_BIT
```

创建 3 个 512×512 的单通道浮点纹理，用作高度图。

#### `_render_process()` — 每帧调度计算

```gdscript
var push_constant := PackedFloat32Array()
push_constant.push_back(wave_point.x)   # 波纹 X 坐标
push_constant.push_back(wave_point.y)   # 波纹 Y 坐标
push_constant.push_back(wave_point.z)   # 波纹强度
push_constant.push_back(wave_point.w)   # 鼠标是否在水面上
push_constant.push_back(tex_size.x)     # 纹理宽度
push_constant.push_back(tex_size.y)     # 纹理高度
push_constant.push_back(p_damp)         # 阻尼系数
```

通过 Push Constant 传递参数到着色器。

#### 鼠标交互

```gdscript
func _check_mouse_pos() -> void:
    var result := get_world_3d().direct_space_state.intersect_ray(parameters)
    if not result.is_empty():
        var pos: Vector3 = global_transform.affine_inverse() * result.position
        add_wave_point.x = clamp(pos.x / 5.0, -0.5, 0.5) * texture_size.x + 0.5 * texture_size.x
        add_wave_point.y = clamp(pos.z / 5.0, -0.5, 0.5) * texture_size.y + 0.5 * texture_size.y
```

通过射线检测获取鼠标在平面上的位置，映射到纹理坐标。

### `water_compute.glsl` — 波纹计算着色器 ⭐

```glsl
layout(r32f, set = 0, binding = 0) uniform restrict readonly image2D current_image;
layout(r32f, set = 1, binding = 0) uniform restrict readonly image2D previous_image;
layout(r32f, set = 2, binding = 0) uniform restrict writeonly image2D output_image;

void main() {
    float current_v = imageLoad(current_image, uv).r;
    float up_v = imageLoad(current_image, clamp(uv - ivec2(0, 1), tl, size)).r;
    float down_v = imageLoad(current_image, clamp(uv + ivec2(0, 1), tl, size)).r;
    float left_v = imageLoad(current_image, clamp(uv - ivec2(1, 0), tl, size)).r;
    float right_v = imageLoad(current_image, clamp(uv + ivec2(1, 0), tl, size)).r;
    float previous_v = imageLoad(previous_image, uv).r;

    float new_v = 2.0 * current_v - previous_v
        + 0.25 * (up_v + down_v + left_v + right_v - 4.0 * current_v);
    new_v = new_v - (params.damp * new_v * 0.001);
}
```

**经典波纹算法：**
```
新值 = 2 × 当前值 - 上一帧值 + 0.25 × (相邻像素和 - 4 × 当前值)
```

### `main.gd` — 场景控制

```gdscript
func _process(delta: float) -> void:
    if $Container/Rotate.button_pressed:
        y += delta
        water_plane.basis = Basis(Vector3.UP, y)
```

控制水面旋转和参数滑块绑定。

---

## 5. 关键概念详解

### 5.1 三纹理循环

```
帧 N:   纹理[0] = 当前, 纹理[1] = 上一帧, 纹理[2] = 写入
帧 N+1: 纹理[1] = 当前, 纹理[2] = 上一帧, 纹理[0] = 写入
帧 N+2: 纹理[2] = 当前, 纹理[0] = 上一帧, 纹理[1] = 写入
```

避免数据拷贝，通过循环 RID 实现历史帧追踪。

### 5.2 `Texture2DRD`

特殊的纹理资源，可以引用直接在渲染设备上创建的纹理 RID，将其暴露给材质着色器使用。

### 5.3 场景结构

```
Main (Node3D)
├── WaterPlane (Area3D)
│   ├── MeshInstance3D
│   │   └── ShaderMaterial (water_shader.gdshader)
│   └── CollisionShape3D
├── WorldEnvironment
├── DirectionalLight3D
└── Container (Control)
    ├── Rotate (Button)
    ├── RainSize (HSlider)
    └── MouseSize (HSlider)
```
