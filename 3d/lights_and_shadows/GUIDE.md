# 3D 光照和阴影 - 源代码导读

> 本文档面向 Godot 新手，剖析光照和阴影演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Lights and Shadows**（`project.godot` 中 `config/name`）

展示 Godot 的各种 3D 光照和阴影功能，包括接触硬化阴影 (PCSS)、光照投影仪、区域光，以及使用 PhysicalSkyMaterial 的昼夜循环。

主场景：`test.tscn`

## 2. 快速上手

左右箭头键切换不同的光照测试示例。鼠标拖拽旋转视角，滚轮缩放。

## 3. 核心架构

```
test.tscn
├── Testers (Node3D)          ← 多个光照测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
├── WorldEnvironment
├── DirectionalLight3D
└── UI (Control)
```

## 4. 文件逐层导读

### `tester.gd` — 主控脚本

与抗锯齿演示相同的测试浏览模式，控制摄像机旋转和测试对象切换。

### `day_night_cycle.gd` — 昼夜循环

**功能：** 控制太阳围绕场景旋转，模拟昼夜变化。

**关键逻辑：**
- 通过 `DirectionalLight3D` 的旋转角度控制时间
- 使用 `PhysicalSkyMaterial` 自动调整天空颜色
- 辐射度贴图实时更新，提供环境光和反射光

### `spin.gd` — 旋转动画

为测试对象添加简单的自转动画效果。

### 光照功能展示

| 功能 | 说明 |
|------|------|
| PCSS 阴影 | 接触硬化阴影，距离光源越近阴影越清晰 |
| 光照投影仪 | 在光源上添加纹理投影 |
| 区域光 | OmniLight3D 和 SpotLight3D 的区域光模式 |
| PhysicalSkyMaterial | 物理天空材质，自动调整天空颜色 |
