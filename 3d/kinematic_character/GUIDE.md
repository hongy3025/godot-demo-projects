# 运动学角色 3D - 源代码导读

> 本文档面向 Godot 新手，剖析运动学角色演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Kinematic Character 3D**（`project.godot` 中 `config/name`）

使用立方体作为角色的 3D 运动学角色演示，与 3D 平台游戏演示类似。

主场景：`level.tscn`

## 2. 快速上手

WASD 移动，空格跳跃，R 重置位置。走到终点平台（TCube）显示胜利文字。

## 3. 核心架构

```
level.tscn
├── Cubio (CharacterBody3D)   ← 玩家角色
│   ├── CollisionShape3D
│   ├── Target (Node3D)
│   │   └── Camera3D
│   ├── MeshInstance3D
│   └── WinText (Label3D)
├── Level (StaticBody3D)      ← 关卡地形
│   └── CollisionShape3D
├── TCube (StaticBody3D)      ← 终点触发区
│   └── CollisionShape3D
└── DirectionalLight3D
```

## 4. 文件逐层导读

### `player/cubio.gd` — 玩家控制脚本

继承 `CharacterBody3D`。

**关键常量：**
```gdscript
const MAX_SPEED = 3.5
const JUMP_SPEED = 6.5
const ACCELERATION = 4
const DECELERATION = 4
```

**`_physics_process()` 核心逻辑：**
1. 获取 WASD 输入方向
2. 将输入方向从摄像机空间转换到世界空间（去除 X 轴旋转）
3. 限制输入向量长度 ≤ 1
4. 应用重力：`velocity.y += delta * gravity`
5. 水平速度插值（加速/减速）
6. 调用 `move_and_slide()` 移动
7. 检测 `is_on_floor()` 和跳跃输入

**摄像机转换关键代码：**
```gdscript
var cam_basis := camera.global_transform.basis
cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
dir = cam_basis * dir
```

### `player/follow_camera.gd` — 跟随摄像机

第三人称跟随摄像机，平滑跟随玩家位置。

### 终点检测

`_on_tcube_body_entered()` 检测玩家进入 TCube 区域后显示胜利文字。
