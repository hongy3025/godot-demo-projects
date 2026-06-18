# 3D 反向动力学 (IK) - 源代码导读

> 本文档面向 Godot 新手，剖析反向动力学演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Inverse Kinematics**（`project.godot` 中 `config/name`）

演示两种 IK（反向动力学）算法：Godot 内置的 `SkeletonIK3D` 和 SADE 插件中的 FABRIK 算法。包含四个场景。

主场景：`look_at_ik.tscn`

## 2. 快速上手

运行后鼠标控制 IK 目标位置，观察骨骼跟随效果。通过按钮切换不同场景。

## 3. 核心架构

```
ik/
├── look_at_ik.tscn           ← LookAt IK 演示
├── fabrik_ik.tscn            ← FABRIK 算法演示
├── fps/                      ← FPS 枪械 IK 演示
├── addons/sade/              ← SADE 插件（FABRIK 实现）
│   ├── ik_fabrik.gd
│   ├── ik_look_at.gd
│   └── plugin_main.gd
└── button_change_scene.gd    ← 场景切换按钮
```

## 4. 文件逐层导读

### `skeleton_ik_runner.gd` — SkeletonIK3D 启动器

```gdscript
extends SkeletonIK3D
func _ready():
    start(false)
```
继承 `SkeletonIK3D`，在 `_ready()` 中调用 `start(false)` 启动 IK 求解。

### `target_from_mousepos.gd` — 鼠标位置转 IK 目标

将鼠标在屏幕上的位置转换为 3D 空间中的 IK 目标位置，通过射线检测确定目标点。

### `addons/sade/ik_fabrik.gd` — FABRIK 算法实现

FABRIK（Forward And Backward Reaching Inverse Kinematics）是一种迭代式 IK 算法：
1. **前向传递：** 从末端执行器向根节点调整骨骼位置
2. **后向传递：** 从根节点向末端执行器调整骨骼位置
3. 重复直到收敛或达到最大迭代次数

### `addons/sade/ik_look_at.gd` — LookAt IK 实现

基于 `Skeleton3D` 的 `set_bone_pose()` 方法，使骨骼朝向目标方向旋转。

### `fps/example_player.gd` — FPS 角色示例

展示 IK 在 FPS 游戏中的应用：手臂持枪 IK、头部追踪等。

### `fps/simple_bullet.gd` — 子弹脚本

简单的子弹物理逻辑。
