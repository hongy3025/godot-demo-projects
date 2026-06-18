# 2D Physics Tests - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

包含一系列 2D 物理引擎的功能测试和性能测试，用于检测回归和评估性能。涵盖刚体堆叠、射线检测、角色碰撞、关节、单向碰撞等。

## 2. 快速上手

运行 `main.tscn`，从菜单选择测试用例。A/D 控制角色，W/空格跳跃，R 重启测试，P 暂停，C 切换碰撞调试显示，F 全屏。

## 3. 核心架构

```
main.tscn
├── TestsMenu              ← 测试菜单
├── Tests (Node)           ← 测试管理器
└── Utils/                 ← 工具脚本（自动加载）
```

## 4. 文件逐层导读

### 测试框架

| 文件 | 作用 |
|------|------|
| `test.gd` | 测试基类，定义测试接口 |
| `tests.gd` | 测试管理器，加载/运行测试 |
| `tests_menu.gd` | 测试选择菜单 UI |

### 功能测试

| 文件 | 测试内容 |
|------|----------|
| `test_stack.gd` | 刚体堆叠稳定性 |
| `test_pyramid.gd` | 金字塔堆叠 |
| `test_raycasting.gd` | 射线检测准确性 |
| `test_joints.gd` | 关节（PinJoint、SpringArm 等） |
| `test_one_way_collision.gd` | 单向碰撞 |
| `test_collision_pairs.gd` | 碰撞配对 |
| `test_character.gd` | CharacterBody2D 基础移动 |
| `test_character_pixels.gd` | 像素级角色移动 |
| `test_character_tilemap.gd` | 角色与 TileMap 碰撞 |

### 性能测试

| 文件 | 测试内容 |
|------|----------|
| `test_perf_broadphase.gd` | 广阶段性能 |
| `test_perf_contacts.gd` | 接触点性能 |

### 工具脚本

| 文件 | 作用 |
|------|------|
| `system.gd` | 自动加载，管理系统设置 |
| `system_log.gd` | 日志系统 |
| `characterbody_controller.gd` | CharacterBody2D 通用控制器 |
| `rigidbody_controller.gd` | RigidBody2D 通用控制器 |
| `rigidbody_pick.gd` | 鼠标拾取刚体 |
| `physics_interpolation.gd` | 物理插值控制 |
| `time_scale.gd` | 时间缩放滑块 |
| `ticks_per_second.gd` | 物理帧率控制 |

## 5. 关键概念详解

### 测试架构

每个测试继承 `test.gd`，实现 `setup()` 和 `teardown()` 方法。`tests.gd` 负责加载测试场景、运行测试和收集结果。

### 自动加载

```gdscript
[autoload]
Log="*res://utils/system_log.gd"
System="*res://utils/system.gd"
```

`Log` 和 `System` 作为全局单例自动加载，所有测试均可访问。

## 6. 如何扩展

- 创建新的测试脚本，继承 `test.gd`
- 在 `tests/` 目录下添加测试文件
- 在 `tests_menu.gd` 中注册新测试
