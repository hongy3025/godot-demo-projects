# Skeleton2D Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 `Skeleton2D` 节点创建 2D 骨骼动画角色。角色 GBot 具有行走、跑步、跳跃、下落、硬着陆等多种动画，通过 `AnimationTree` 混合控制。

## 2. 快速上手

运行 `level.tscn`，A/D 左右移动，W/空格跳跃，Shift 慢走。观察角色在不同动作间的平滑过渡。

## 3. 核心架构

```
level.tscn
├── Level (Node2D)
│   ├── Ground (TileMapLayer)
│   ├── CameraLimit_min (Marker2D)
│   └── CameraLimit_max (Marker2D)
└── Player (CharacterBody2D)
    ├── Sprite2D
    │   ├── Skeleton2D
    │   └── AnimationTree
    └── Camera2D
```

## 4. 文件逐层导读

### `player/player.gd` — 玩家控制 ⭐

**状态管理：**
```gdscript
const States = {
    IDLE = "idle",
    WALK = "walk",
    RUN = "run",
    FLY = "fly",
    FALL = "fall",
}
```

**AnimationTree 控制：**
```gdscript
# 跳跃触发
$AnimationTree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

# 硬着陆触发
$AnimationTree["parameters/land_hard/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

# 状态切换
$AnimationTree["parameters/state/transition_request"] = States.RUN

# 动画速度缩放
$AnimationTree["parameters/run_timescale/scale"] = abs(velocity.x) / 60
```

**动画状态机：**
- 地面：IDLE ↔ WALK ↔ RUN（根据速度）
- 空中：FLY（上升）↔ FALL（下落）
- 跳跃/着陆：OneShot 节点，播放后自动恢复

### `level/level.gd` — 关卡

```gdscript
func _ready():
    var camera = find_child("Camera2D")
    camera.limit_left = round(min_pos.x)
    camera.limit_top = round(min_pos.y)
    camera.limit_right = round(max_pos.x)
    camera.limit_bottom = round(max_pos.y)
```

## 5. 关键概念详解

### Skeleton2D 骨骼系统

`Skeleton2D` 是 2D 骨骼动画的核心：
- 骨骼（Bone2D）组成层级结构
- 精灵（Sprite2D）通过骨骼权重绑定到骨骼
- 动画（Animation）驱动骨骼的旋转/缩放/位移

### AnimationTree 混合

`AnimationTree` 提供高级动画控制：
- `StateMachine`：管理状态切换（idle/walk/run/fly/fall）
- `OneShot`：播放一次性动画（跳跃/着陆）
- `TimeScale`：根据移动速度调整动画播放速度

## 6. 场景树全景

```
Level (Node2D)
├── TileMapLayer
├── CameraLimit_min
├── CameraLimit_max
└── Player (CharacterBody2D)
    ├── Sprite2D
    │   ├── Skeleton2D
    │   │   ├── Bone2D (root)
    │   │   ├── Bone2D (body)
    │   │   └── ...
    │   └── AnimationTree
    ├── CollisionShape2D
    └── Camera2D
```

## 7. 如何扩展

- 在 `AnimationTree` 中添加新的状态（如攀爬、游泳）
- 修改骨骼结构创建不同角色
- 添加武器骨骼，实现武器跟随手部动画
