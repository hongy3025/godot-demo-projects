# 3D in 2D - 源代码导读

> 本文档面向 Godot 新手，讲解如何通过 SubViewport 在 2D 场景中嵌入 3D 内容。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [场景树全景](#4-场景树全景)

---

## 1. 项目概述

演示如何在 2D 场景的 Sprite 上显示一个 3D 机器人模型。核心思路是将 3D 场景渲染到 `SubViewport`，然后将其纹理作为 `Sprite2D` 的贴图。

---

## 2. 核心架构

```
3D 场景 (机器人)
    ↓ 渲染到
SubViewport
    ↓ get_texture()
ViewportTexture
    ↓ 赋值给
Sprite2D 的 texture
```

---

## 3. 文件逐层导读

### `3d_in_2d.gd` — 2D 场景控制

```gdscript
extends Node2D

func _ready() -> void:
    $AnimatedSprite2D.play()
    get_viewport().size_changed.connect(_root_viewport_size_changed)

func _root_viewport_size_changed() -> void:
    viewport.size = Vector2.ONE * get_viewport().size.y
    viewport_sprite.scale = Vector2.ONE * viewport_initial_size.y / get_viewport().size.y
```

**自适应分辨率：** 窗口大小变化时，SubViewport 大小随窗口高度调整，同时缩放 Sprite 以保持显示质量。

### `robot_3d.gd` — 3D 机器人旋转

```gdscript
extends Node

func _process(delta: float) -> void:
    model.rotation.y += delta * 0.7
```

让机器人模型缓慢自转，展示 3D 效果。

---

## 4. 场景树全景

```
3D_in_2D (Node2D)
├── AnimatedSprite2D        ← 背景动画
├── SubViewport             ← 3D 渲染目标
│   └── Robot3D (Node)
│       ├── Camera3D
│       ├── Model (Node3D)  ← robot.glb 模型
│       └── DirectionalLight3D
└── ViewportSprite (Sprite2D)  ← 显示 3D 画面的 2D 精灵
    texture = SubViewport.get_texture()
```
