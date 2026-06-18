# OpenXR Character Centric Movement - 源代码导读

> 本文档面向 Godot 新手，讲解 VR 中基于 CharacterBody3D 的玩家移动方案。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 VR 中"以角色身体为中心"的移动方案。`CharacterBody3D` 作为根节点，`XROrigin3D` 作为子节点。物理移动和虚拟移动都通过 CharacterBody3D 处理。

---

## 2. 核心架构

```
CharacterBody3D (根节点)
├── XROrigin3D
│   ├── XRCamera3D
│   │   ├── Neck (定位参考点)
│   │   └── BlackOut (碰撞时黑屏)
│   ├── LeftHand (XRController3D)
│   └── RightHand (XRController3D)
```

---

## 3. 文件逐层导读

### `player.gd` — 核心移动逻辑 ⭐

**物理移动处理 (`_process_on_physical_movement`)：**

```gdscript
# 1. 将玩家朝向与真实头部朝向同步
var camera_basis = origin_node.transform.basis * camera_node.transform.basis
transform.basis = transform.basis.rotated(Vector3.UP, angle)

# 2. 计算 CharacterBody 应该移动到的位置
var player_body_location = origin_node.transform * camera_node.transform * neck_position_node.transform.origin

# 3. 尝试移动 CharacterBody
velocity = (player_body_location - org_player_body) / delta
move_and_slide()

# 4. 将 XROrigin 反向移动以补偿
origin_node.global_transform.origin -= delta_movement
```

**虚拟移动处理 (`_process_movement_on_input`)：**

```gdscript
# 摇杆 X 轴 → 旋转
rotation.y += -movement_input.x * delta * rotation_speed

# 摇杆 Y 轴 → 前进/后退
var direction = global_transform.basis * Vector3(0, 0, -movement_input.y) * movement_speed
```

**碰撞检测：** 如果 CharacterBody 无法移动到目标位置（遇到障碍物），`BlackOut` 节点的透明度增加，实现"黑屏"效果。

### `start_vr.gd` — 标准 OpenXR 初始化

---

## 4. 关键概念详解

### CharacterBody 方案 vs XROrigin 方案

| | CharacterBody 方案（本 demo） | XROrigin 方案 |
|---|---|---|
| 根节点 | CharacterBody3D | XROrigin3D |
| 物理移动 | 移动 CharacterBody，反向移动 XROrigin | 移动 CharacterBody，同步移动 XROrigin |
| 虚拟移动 | 标准 move_and_slide() | 需要额外数学计算 |
| 碰撞处理 | 原生支持 | 需要手动处理 |

### 物理移动流程

```
玩家在现实中走动
    ↓
XRCamera3D 位置变化
    ↓
计算 CharacterBody 应处位置
    ↓
move_and_slide() 尝试移动
    ↓
成功 → XROrigin 反向补偿
失败 → 黑屏效果
```
