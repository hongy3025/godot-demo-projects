# 3D 物理测试 - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 物理测试项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Physics Tests**（`project.godot` 中 `config/name`）

包含一系列针对 3D 物理引擎的功能测试和性能测试，用于检查回归问题和比较不同物理引擎的行为。

主场景：`main.tscn`

## 2. 快速上手

通过菜单选择不同的物理测试。R 重启测试，P 暂停，C 切换碰撞显示，F 全屏。

## 3. 核心架构

```
physics_tests/
├── main.tscn                 ← 主菜单
├── tests_menu.gd             ← 测试菜单
├── tests.gd                  ← 测试管理器
├── test.gd                   ← 测试基类
├── tests/
│   ├── functional/           ← 功能测试
│   │   ├── test_stack.gd
│   │   ├── test_pyramid.gd
│   │   ├── test_joints.gd
│   │   ├── test_raycasting.gd
│   │   ├── test_moving_platform.gd
│   │   ├── test_collision_pairs.gd
│   │   └── test_rigidbody_ground_check.gd
│   └── performance/          ← 性能测试
│       ├── test_perf_contacts.gd
│       └── test_perf_broadphase.gd
└── utils/                    ← 工具脚本
    ├── system.gd             ← 系统单例
    ├── system_log.gd         ← 日志单例
    ├── camera_orbit.gd       ← 摄像机控制
    ├── characterbody_physics.gd
    ├── control3d.gd
    └── ...
```

## 4. 文件逐层导读

### `test.gd` — 测试基类

所有测试继承此类，提供统一的接口：
- `start()` — 开始测试
- `stop()` — 停止测试
- `restart()` — 重新开始

### 功能测试

| 测试 | 说明 |
|------|------|
| test_stack | 堆叠刚体测试 |
| test_pyramid | 金字塔排列测试 |
| test_joints | 关节约束测试 |
| test_raycasting | 射线检测测试 |
| test_moving_platform | 移动平台测试 |
| test_collision_pairs | 碰撞对测试 |
| test_rigidbody_ground_check | 刚体地面检测测试 |

### 性能测试

| 测试 | 说明 |
|------|------|
| test_perf_contacts | 大量接触的性能测试 |
| test_perf_broadphase | 宽相位检测性能测试 |

### 工具脚本

| 脚本 | 作用 |
|------|------|
| `system.gd` | 系统单例，管理测试生命周期 |
| `system_log.gd` | 日志系统单例 |
| `camera_orbit.gd` | 轨道摄像机控制 |
| `characterbody_physics.gd` | CharacterBody3D 物理工具 |
