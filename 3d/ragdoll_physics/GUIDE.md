# 布娃娃物理 - 源代码导读

> 本文档面向 Godot 新手，剖析布娃娃物理演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Ragdoll Physics**（`project.godot` 中 `config/name`）

角色布娃娃模拟的示例，包含碰撞音效、慢动作模式和角色轮廓效果。

主场景：`uid://dpkhlaxg5302f`

## 2. 快速上手

**Space** 在鼠标位置添加布娃娃，**Shift** 慢动作（1/4 速度），**R** 重置，鼠标右键环绕视角，滚轮缩放。

## 3. 核心架构

```
main.tscn
├── WorldEnvironment
├── DirectionalLight3D
├── Ground (StaticBody3D)     ← CSG 烘焙的静态几何体
├── Camera3D
└── UI
```

## 4. 文件逐层导读

### `ragdoll_physics.gd` — 场景主控

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_input()` | 处理 Space（放置布娃娃）、Shift（慢动作）、R（重置） |
| `_physics_process()` | 更新布娃娃物理 |

**慢动作实现：**
```gdscript
Engine.time_scale = 0.25  # 1/4 速度
AudioServer.playback_speed_scale = 0.25  # 音频同步降调
```

### `characters/mannequiny_ragdoll.gd` — 布娃娃角色

**关键特性：**
- `initial_velocity` 变量：为所有骨骼施加初始冲量
- 碰撞音效：根据碰撞速度播放，慢动作时降调
- 角色轮廓：使用 `BaseMaterial3D` 的 Stencil 模式

### 布娃娃设置

按照 [Ragdoll 系统教程](https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html) 设置：
1. 创建 `PhysicalBone3D` 节点
2. 设置骨骼碰撞形状
3. 添加关节约束
4. 激活布娃娃模拟

### 场景几何体

使用 CSG 节点设计，烘焙为静态网格和碰撞体，改善加载时间并允许使用 LightmapGI 进行全局光照。
