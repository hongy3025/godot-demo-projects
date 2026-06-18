# Truck Town - 源代码导读

> 本文档面向 Godot 新手，剖析车辆物理演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Truck Town**（`project.godot` 中 `config/name`）

使用车辆物理实现不同复杂度卡车的演示，包含基础卡车、拖车卡车和拖车。

主场景：`car_select/car_select.tscn`

## 2. 快速上手

W 加速，S/空格刹车/倒车，A/D 转向。**C** 切换摄像机，**M** 切换氛围（日出/白天/日落/夜晚），**Shift** 加速，**H** 喇叭，**L** 车灯。

## 3. 核心架构

```
truck_town/
├── car_select/               ← 车辆选择
│   └── car_select.tscn
├── town/                     ← 城镇场景
│   └── town_scene.tscn
├── vehicles/                 ← 车辆逻辑
│   ├── vehicle.gd
│   └── follow_camera.gd
└── speedometer.gd            ← 速度表
```

## 4. 文件逐层导读

### `vehicles/vehicle.gd` — 车辆控制

基于 `VehicleBody3D` 节点。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_physics_process()` | 处理加速/刹车/转向输入 |
| `_process()` | 更新速度表、车灯等 |

**车辆类型：**

| 类型 | 实现方式 |
|------|---------|
| 基础卡车 | `VehicleBody3D` + `VehicleWheel3D` |
| 拖车卡车 | `VehicleBody3D` + `ConeJointTwist3D` 连接拖车 |
| 拖车 | `RigidBody3D` 链条 + `PinJoint3D` 连接 |

### `vehicles/follow_camera.gd` — 跟随摄像机

三种摄像机模式：外部、内部、俯视。

### `speedometer.gd` — 速度表

显示当前速度，支持 m/s、km/h、mph 单位切换。

### `car_select/car_select.gd` — 车辆选择

车辆选择菜单逻辑。

### `town/town_scene.gd` — 城镇场景

管理城镇环境、氛围切换、环境音效。

### 氛围系统

| 氛围 | 说明 |
|------|------|
| Sunrise | 日出，暖色调 |
| Day | 白天，标准光照 |
| Sunset | 日落，暖色调 |
| Night | 夜晚，车灯自动开启 |
