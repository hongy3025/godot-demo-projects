# Compositor Effects (Post-Processing) - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用合成器效果（Compositor Effect）实现基于计算着色器的后处理"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的合成器效果技术演示项目（需要 Forward+ 渲染器）。核心思路是：

> **继承 `CompositorEffect` 资源类，在渲染管线的后透明阶段插入计算着色器，实现全屏后处理效果。**

项目包含两种实现方式：
| 方式 | 文件 | 特点 |
|------|------|------|
| **模板着色器** | `post_process_shader.gd` | 运行时注入用户代码，可动态重编译 |
| **文件着色器** | `post_process_grayscale.gd` + `.glsl` | 预编译，性能更好 |

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

按 G 键切换灰度效果，按 S 键切换着色器效果。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│          场景层 (main.tscn)                 │
│  WorldEnvironment → Compositor              │
├─────────────────────────────────────────────┤
│       合成器效果层 (CompositorEffect)       │
│  post_process_shader.gd / grayscale.gd      │
├─────────────────────────────────────────────┤
│      计算着色器层 (GLSL)                    │
│  8×8 工作组 → 全屏像素处理                  │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `main.gd` — 场景控制

```gdscript
func _input(input_event: InputEvent) -> void:
    if input_event.is_action_pressed(&"toggle_grayscale_effect"):
        compositor.compositor_effects[0].enabled = not compositor.compositor_effects[0].enabled
    if input_event.is_action_pressed(&"toggle_shader_effect"):
        compositor.compositor_effects[1].enabled = not compositor.compositor_effects[1].enabled
```

通过按键切换两个合成器效果的启用状态。

### `post_process_grayscale.gd` — 灰度效果 ⭐

**继承自 `CompositorEffect`**，最简单的实现。

```gdscript
func _init() -> void:
    effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
    rd = RenderingServer.get_rendering_device()
    RenderingServer.call_on_render_thread(_initialize_compute)
```

- 设置回调阶段为"后透明"
- 在渲染线程上初始化计算着色器

#### `_render_callback()` — 每帧调用

```gdscript
var x_groups := (size.x - 1) / 8 + 1
var y_groups := (size.y - 1) / 8 + 1
var compute_list := rd.compute_list_begin()
rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
rd.compute_list_end()
```

1. 计算工作组数量（确保覆盖全屏）
2. 绑定计算管线
3. 设置 Push Constant（屏幕尺寸）
4. 调度计算

### `post_process_grayscale.glsl` — 灰度着色器

```glsl
layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

void main() {
    vec4 color = imageLoad(color_image, uv);
    float gray = color.r * 0.2125 + color.g * 0.7154 + color.b * 0.0721;
    color.rgb = vec3(gray);
    imageStore(color_image, uv, color);
}
```

标准灰度转换公式（ITU-R BT.601 亮度系数）。

### `post_process_shader.gd` — 模板着色器效果 ⭐

**特点：** 运行时将用户代码注入模板，支持动态重编译。

```gdscript
const TEMPLATE_SHADER: String = """... #COMPUTE_CODE ..."""

@export_multiline var shader_code: String = "":
    set(value):
        shader_is_dirty = true
```

#### `_check_shader()` — 按需重编译

```gdscript
new_shader_code = TEMPLATE_SHADER.replace("#COMPUTE_CODE", new_shader_code)
var shader_source := RDShaderSource.new()
shader_source.source_compute = new_shader_code
var shader_spirv := rd.shader_compile_spirv_from_source(shader_source)
```

将用户代码注入模板，编译 SPIR-V，创建计算管线。

---

## 5. 关键概念详解

### 5.1 `CompositorEffect` 工作流程

```
1. 继承 CompositorEffect
2. 设置 effect_callback_type（如 POST_TRANSPARENT）
3. 实现 _render_callback()
4. 在场景的 WorldEnvironment.compositor 中添加此效果
5. 每帧渲染时自动调用 _render_callback()
```

### 5.2 两种实现方式对比

| 特性 | 模板着色器 | 文件着色器 |
|------|-----------|-----------|
| 着色器代码位置 | 脚本属性 | `.glsl` 文件 |
| 编译时机 | 属性变化时 | 初始化时 |
| 运行时修改 | 支持 | 需重载场景 |
| 着色器缓存 | 不支持 | 支持 |
| 适用场景 | 开发/调试 | 发布/生产 |

### 5.3 场景结构

```
Main (Node3D)
├── WorldEnvironment
│   └── Compositor
│       ├── PostProcessGrayScale (CompositorEffect)
│       └── PostProcessShader (CompositorEffect)
├── MeshInstance3D
├── DirectionalLight3D
└── Info (Label3D)
```
