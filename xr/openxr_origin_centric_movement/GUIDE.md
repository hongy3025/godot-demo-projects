# OpenXR Origin Centric Movement - 源代码导读

> 本文档面向 Godot 新手，讲解 VR 中基于 XROrigin3D 的玩家移动方案。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 VR 中"以原点为中心"的移动方案。`XROrigin3D` 作为根节点，`CharacterBody3D` 作为子节点。这是较早期的 VR 移动方案，原点位置更清晰地映射到虚拟世界。

---

## 2. 核心架构

```
XROrigin3D (根节点)
├── XRCamera3D
│   ├── Neck (定位参考点)
│   └── BlackOut (碰撞时黑屏)
├── LeftHand (XRController3D)
├── RightHand (XRController3D)
└── CharacterBody3D (碰撞检测)
```

---

## 3. 文件逐层导读

### `player.gd` — 核心移动逻辑 ⭐

**物理移动处理：**

```gdscript
func _process_on_physical_movement(delta: float) -> bool:
    # 计算 CharacterBody 应处位置
    var player_body_location = camera_node.transform * neck_position_node.transform.origin
    player_body_location.y = 0.0
    player_body_location = global_transform * player_body_location

    # 尝试移动 CharacterBody
    character_body.velocity = (player_body_location - org_player_body) / delta
    character_body.move_and_slide()

    # 检查是否被阻挡
    var movement_left := player_body_location - character_body.global_transform.origin
    if movement_left.length() > 0.1:
        black_out.fade = clamp(...)  # 黑屏
        return true
```

**虚拟移动处理（摇杆旋转）：**

```gdscript
# 围绕 CharacterBody 旋转 XROrigin
var player_position := character_body.global_transform.origin - global_transform.origin
t1.origin = -player_position
t2.origin = player_position
rot = rot.rotated(Vector3.UP, -movement_input.x * delta * rotation_speed)
global_transform = (global_transform * t2 * rot * t1).orthonormalized()
```

**虚拟移动后同步：**

```gdscript
# 将 CharacterBody 的位移应用到 XROrigin
global_transform.origin += character_body.global_transform.origin - org_player_body
```

### `start_vr.gd` — 标准 OpenXR 初始化

---

## 4. 关键概念详解

### Origin 方案 vs CharacterBody 方案

| | Origin 方案（本 demo） | CharacterBody 方案 |
|---|---|---|
| 根节点 | XROrigin3D | CharacterBody3D |
| 旋转计算 | 围绕 CharacterBody 旋转 Origin | 直接旋转 CharacterBody |
| 位移同步 | 手动将 CharacterBody 位移加到 Origin | 自动通过 move_and_slide |
| 复杂度 | 较高（需要更多数学） | 较低 |

### 摇杆旋转的数学原理

```
1. 将 CharacterBody 位置平移到原点
2. 应用旋转矩阵
3. 平移回原位
4. 正交化防止缩放漂移
```
