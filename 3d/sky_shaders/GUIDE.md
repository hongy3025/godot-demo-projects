# 3D 天空着色器 - 源代码导读

> 本文档面向 Godot 新手，剖析天空着色器演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Sky Shaders**（`project.godot` 中 `config/name`）

使用天空着色器渲染实时体积云和物理天空（瑞利散射 + 米氏散射），包含昼夜循环动画。

主场景：`Main.tscn`

## 2. 快速上手

鼠标环顾，**F1** 切换 UI，**F2** 切换球体显隐，**上/下箭头** 调整 FOV。昼夜循环自动播放。

## 3. 核心架构

```
Main.tscn
├── WorldEnvironment
│   └── Sky (ShaderMaterial)  ← 自定义天空着色器
├── DirectionalLight3D        ← 太阳（驱动天空）
├── AnimationPlayer           ← 昼夜循环动画
├── Spheres (Node3D)          ← @tool 脚本生成的测试球体
├── Camera3D
└── UI (Control)
```

## 4. 文件逐层导读

### `main.gd` — 场景主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化场景 |
| `_input()` | 处理 F1/F2/FOV 等快捷键 |

### `spheres.gd` — 球体生成

**`@tool` 脚本：** 在编辑器中运行，自动生成具有不同粗糙度和金属度的球体。

```gdscript
@tool  # 允许在编辑器中执行
extends Node3D

func _ready():
    # 自动创建测试球体
    for i in range(10):
        var sphere = MeshInstance3D.new()
        # 设置材质参数...
        add_child(sphere)
```

### 天空着色器

基于 `PhysicalSkyMaterial` 转换为 `ShaderMaterial` 后添加体积云：

| 特性 | 说明 |
|------|------|
| 瑞利散射 | 天空蓝色散射 |
| 米氏散射 | 云层散射 |
| 体积云 | 实时 3D 噪声云 |
| 昼夜循环 | AnimationPlayer 驱动 |

### 性能警告

> 天空着色器每帧渲染，复杂着色器性能开销大。适用于飞行模拟器等大部分天空始终可见的游戏。
