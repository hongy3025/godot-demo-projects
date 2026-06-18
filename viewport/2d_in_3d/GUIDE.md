# 2D in 3D - 源代码导读

> 本文档面向 Godot 新手，讲解如何通过 SubViewport 在 3D 场景中嵌入 2D 内容。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [场景树全景](#4-场景树全景)

---

## 1. 项目概述

演示如何在 3D 场景的四边形网格上显示一个 2D Pong 游戏画面。核心思路是将 2D 游戏渲染到 `SubViewport`，然后将其纹理作为 3D 材质的贴图。

---

## 2. 核心架构

```
2D 场景 (Pong 游戏)
    ↓ 渲染到
SubViewport
    ↓ get_texture()
ViewportTexture
    ↓ 赋值给
3D Quad 的材质 albedo_texture
```

---

## 3. 文件逐层导读

### `2d_in_3d.gd` — 3D 场景控制

```gdscript
extends Node3D

func _ready() -> void:
    var viewport: SubViewport = $SubViewport
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
    $ViewportQuad.material_override.albedo_texture = viewport.get_texture()
```

- `render_target_clear_mode = CLEAR_MODE_ONCE` — 只在首次清除，避免闪烁
- `viewport.get_texture()` — 获取 `ViewportTexture`，这是连接 2D 和 3D 的关键

相机有微弱的 idle 动画（`cos/sin` 产生轻微摆动）。

### `pong.gd` — 2D Pong 游戏

继承 `Node2D`，实现经典 Pong 逻辑：
- 球体移动、碰撞检测（墙壁和球拍）
- 球拍由 W/S（左）和方向键上/下（右）控制
- 得分后重置球位置
- 每次击球加速 10%

---

## 4. 场景树全景

```
2D_in_3D (Node3D)
├── Camera3D                ← 3D 相机（带 idle 动画）
├── SubViewport             ← 2D 渲染目标
│   └── Pong (Node2D)      ← 2D Pong 游戏
│       ├── Ball (Sprite2D)
│       ├── LeftPaddle (Sprite2D)
│       └── RightPaddle (Sprite2D)
├── DirectionalLight3D
└── ViewportQuad (MeshInstance3D)  ← 显示 2D 画面的 3D 四边形
    └── material_override  ← 材质，albedo_texture = SubViewport.get_texture()
```
