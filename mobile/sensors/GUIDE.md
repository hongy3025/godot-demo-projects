# 移动传感器演示 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用移动设备的加速度计、陀螺仪和磁力计"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的移动传感器演示项目。核心功能是：

> **使用加速度计、陀螺仪和磁力计数据，在 3D 场景中可视化设备朝向，并演示两种朝向计算方法（磁力计+重力 vs 陀螺仪+重力漂移校正）。**

功能包括：
- 实时显示加速度计、重力、磁力计、陀螺仪数值
- 3D 箭头可视化各传感器向量方向
- 两种朝向计算方法对比（两个立方体）
- 指向磁北的箭头

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

### 2.2 操作说明

此演示在移动设备上运行，无需用户操作。旋转设备观察：
- 箭头方向随设备姿态变化
- 两个立方体的朝向对比
- 传感器数值实时更新

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          可视化层                     │
│  3D 箭头 / 立方体 / 数值显示        │
├──────────────────────────────────────┤
│          传感器计算层                 │
│  get_basis_for_arrow()               │
│  calc_north()                        │
│  orientate_by_mag_and_grav()         │
│  rotate_by_gyro()                    │
│  drift_correction()                  │
├──────────────────────────────────────┤
│         Godot 传感器 API             │
│  Input.get_accelerometer()           │
│  Input.get_gravity()                 │
│  Input.get_magnetometer()            │
│  Input.get_gyroscope()               │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `main.gd` — 主控制脚本 ⭐

**地位：** 项目的核心，包含所有传感器数据处理和可视化逻辑。

**传感器数据获取：**

```gdscript
func _process(delta: float) -> void:
    var acc := Input.get_accelerometer()
    var grav := Input.get_gravity()
    var mag := Input.get_magnetometer()
    var gyro := Input.get_gyroscope()
```

**箭头方向计算：**

```gdscript
func get_basis_for_arrow(p_vector: Vector3) -> Basis:
    var rotate := Basis()
    rotate.y = p_vector.normalized()       # Y = 方向向量
    var v := Vector3(1.0, 0.0, 0.0)
    if abs(v.dot(rotate.y)) > 0.9:         # 避免与方向向量平行
        v = Vector3(0.0, 1.0, 0.0)
    rotate.x = rotate.y.cross(v).normalized()
    rotate.z = rotate.x.cross(rotate.y).normalized()
    return rotate
```

**磁北计算：**

```gdscript
func calc_north(p_grav: Vector3, p_mag: Vector3) -> Vector3:
    p_grav = p_grav.normalized()
    var east := p_grav.cross(p_mag.normalized()).normalized()
    return east.cross(p_grav).normalized()
```

**方法一：磁力计 + 重力**

```gdscript
func orientate_by_mag_and_grav(p_mag: Vector3, p_grav: Vector3) -> Basis:
    var rotate := Basis()
    rotate.y = -p_grav.normalized()        # 上方向
    rotate.x = rotate.y.cross(p_mag)       # 东/西方向
    rotate.z = rotate.x.cross(rotate.y)    # 北方向
    return rotate
```

**方法二：陀螺仪 + 重力漂移校正**

```gdscript
func rotate_by_gyro(p_gyro: Vector3, p_basis: Basis, p_delta: float) -> Basis:
    var rotate := Basis()
    rotate = rotate.rotated(p_basis.x, -p_gyro.x * p_delta)
    rotate = rotate.rotated(p_basis.y, -p_gyro.y * p_delta)
    rotate = rotate.rotated(p_basis.z, -p_gyro.z * p_delta)
    return rotate * p_basis
```

**漂移校正：**

```gdscript
func drift_correction(p_basis: Basis, p_grav: Vector3) -> Basis:
    var real_up := -p_grav.normalized()
    var dot := p_basis.y.dot(real_up)
    if dot < 1.0:
        var axis := p_basis.y.cross(real_up).normalized()
        var correction := Basis(axis, acos(dot))
        p_basis = correction * p_basis
    return p_basis
```

---

## 5. 关键概念详解

### 5.1 四种传感器

| 传感器 | 返回值 | 说明 |
|--------|--------|------|
| 加速度计 | `Vector3` | 设备加速度（含重力） |
| 重力 | `Vector3` | 重力方向向量 |
| 磁力计 | `Vector3` | 磁场方向（指向磁北） |
| 陀螺仪 | `Vector3` | 角速度（rad/s） |

### 5.2 两种朝向计算方法对比

| 方法 | 优点 | 缺点 |
|------|------|------|
| **磁力计+重力** | 稳定，无漂移 | 易受磁场干扰，便宜手机无陀螺仪时可用 |
| **陀螺仪+重力校正** | 精度高，响应快 | 有累积漂移，需要漂移校正 |

### 5.3 漂移校正原理

陀螺仪积分会产生累积误差（漂移）。通过重力向量校正：
1. 计算当前上方向与重力方向的夹角
2. 构造旋转矩阵校正偏差
3. 应用校正到当前朝向

### 5.4 北方向计算

```
重力向量 ↓
磁力计向量 → 叉积 → 东方向
东方向 × 重力 → 北方向（水平）
```

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Node)
├── Arrows
│   ├── AccelerometerArrow (MeshInstance3D)  ← 重力方向箭头
│   ├── MagnetoArrow (MeshInstance3D)        ← 磁场方向箭头
│   └── NorthArrow (MeshInstance3D)          ← 磁北方向箭头
├── Boxes
│   ├── MagAndGrav (MeshInstance3D)          ← 方法一：立方体
│   └── GyroAndGrav (MeshInstance3D)         ← 方法二：立方体
├── Camera3D
├── DirectionalLight3D
└── Labels (传感器数值显示)
    ├── AccX/Y/Z
    ├── GravX/Y/Z
    ├── MagX/Y/Z
    └── GyroX/Y/Z
```

---

## 7. 如何扩展

### 7.1 添加低通滤波

传感器数据通常包含噪声，添加简单滤波：

```gdscript
var filtered_acc := lerp(prev_acc, acc, 0.5)  # 简单低通
```

### 7.2 实现指南针

使用 `calc_north()` 的结果驱动 2D 指南针 UI。

### 7.3 步数检测

分析加速度计数据，检测行走步数：

```gdscript
var magnitude := acc.length()
if magnitude > THRESHOLD and not is_step:
    is_step = true
    step_count += 1
elif magnitude < THRESHOLD:
    is_step = false
```

---

## 推荐阅读路径

1. **`main.gd`** — 理解所有传感器数据处理的核心逻辑
2. **`main.tscn`** — 查看 3D 场景结构
