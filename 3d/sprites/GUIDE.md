# 3D 精灵和动画精灵 - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 精灵演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Sprites and Animated Sprites**（`project.godot` 中 `config/name`）

展示 Sprite3D 和 AnimatedSprite3D 在 3D 空间中的使用，以及应用于精灵的着色器效果。

主场景：`uid://b15ro0v2x7n5t`

## 2. 快速上手

WASD 移动，方向键切换不同的精灵示例。观察精灵的公告板效果和着色器效果。

## 3. 核心架构

```
main.tscn
├── Sprites (Node3D)          ← 多个精灵测试对象
├── Player (CharacterBody3D)
├── Camera3D
└── UI
```

## 4. 文件逐层导读

### `scripts/3d_sprites.gd` — 主控脚本

管理场景中的精灵展示和切换。

### `scripts/sprite_rotate.gd` — 精灵旋转

为精灵添加旋转动画，展示 Sprite3D 在 3D 空间中的基本变换。

### `scripts/player.gd` — 玩家控制

简单的第一人称控制器，用于在场景中移动观察精灵。

### Sprite3D vs AnimatedSprite3D

| 特性 | Sprite3D | AnimatedSprite3D |
|------|----------|-----------------|
| 单帧纹理 | 支持 | 支持 |
| 帧动画 | 不支持 | 支持（SpriteFrames） |
| 公告板 | 支持 | 支持 |
| 着色器 | 支持 | 支持 |

### 着色器效果

| 效果 | 说明 |
|------|------|
| 轮廓效果 | 模拟物体轮廓线 |
| 光照效果 | 模拟光照响应 |
| 纸张效果 | 类似纸张的视觉风格 |
