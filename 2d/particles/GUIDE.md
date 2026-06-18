# 2D GPUParticles - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示 Godot 2D GPU 粒子系统（`GPUParticles2D`）的各种效果，包括粒子拖尾（Trails）、辉光（Glow）等。

## 2. 快速上手

运行 `particles.tscn`，空格暂停/继续，T 切换拖尾，上/下方向键调整拖尾长度，G 切换辉光。

## 3. 核心架构

```
particles.tscn
├── WorldEnvironment       ← 辉光效果
├── GPUParticles2D ×N     ← 多种粒子效果
└── CanvasLayer
    └── Label (Pause)     ← 操作提示
```

## 4. 文件逐层导读

### `pause.gd` — 粒子控制

```gdscript
func _input(input_event):
    if input_event.is_action_pressed(&"toggle_pause"):
        get_tree().paused = not get_tree().paused

    if not is_compatibility and input_event.is_action_pressed(&"toggle_trails"):
        for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
            particles.trail_enabled = not particles.trail_enabled
```

**兼容性检测：**
```gdscript
if RenderingServer.get_current_rendering_method() == "gl_compatibility":
    is_compatibility = true
```

Compatibility 渲染器不支持拖尾功能，因此隐藏相关 UI 并增加辉光强度补偿。

## 5. 关键概念详解

### GPUParticles2D

GPU 粒子系统在 GPU 上计算粒子运动，适合大量粒子（数千到数万）。

### ParticleProcessMaterial

粒子处理材质定义粒子的行为：
- `direction`：发射方向
- `spread`：扩散角度
- `gravity`：重力
- `initial_velocity`：初始速度
- `scale`：粒子大小变化

**注意：** `ParticleProcessMaterial` 在 2D 和 3D 中通用，2D 使用时需启用"Disable Z"。

### 粒子拖尾（Trails）

拖尾让粒子留下运动轨迹，通过 `trail_enabled` 和 `trail_lifetime` 控制。

## 6. 场景树全景

```
Particles (Node2D)
├── WorldEnvironment
├── GPUParticles2D (Fire)
├── GPUParticles2D (Smoke)
├── GPUParticles2D (Sparkles)
├── ...
└── CanvasLayer
    └── Label (Pause)
    └── Label (UnsupportedLabel)
```

## 7. 如何扩展

- 复制现有 `GPUParticles2D` 节点，修改 `ParticleProcessMaterial` 参数创建新效果
- 使用 `GPUParticles2D.amount` 控制粒子数量
- 结合 `GpuParticlesAttractor2D` 实现粒子吸引效果
