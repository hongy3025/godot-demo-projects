# Physics-Based Platformer 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

使用 `RigidBody2D` 实现玩家和敌人的物理驱动平台游戏。与 `CharacterBody2D` 不同，`RigidBody2D` 完全受物理引擎控制，需要手动修改速度。支持跷跷板、骑乘敌人等物理交互。

## 2. 快速上手

运行 `stage.tscn`，A/D 左右移动，W/上方向键跳跃，空格/鼠标左键射击，R 生成敌人。

## 3. 核心架构

```
stage.tscn
├── Player (RigidBody2D)  ← 物理驱动玩家
├── Ground (StaticBody2D) ← 地面
├── SeeSaw (RigidBody2D)  ← 跷跷板
├── Enemy (RigidBody2D)   ← 敌人
└── Coin (Area2D)         ← 金币
```

## 4. 文件逐层导读

### `player/player.gd` — 物理玩家 ⭐

**核心差异：** 使用 `_integrate_forces()` 而非 `_physics_process()`。

```gdscript
func _integrate_forces(state: PhysicsDirectBodyState2D):
    var velocity := state.get_linear_velocity()
    var step := state.get_step()
```

**地面检测：** 手动遍历碰撞接触点，检测法线朝上的接触。
```gdscript
for contact_index in state.get_contact_count():
    var collision_normal := state.get_contact_local_normal(contact_index)
    if collision_normal.dot(Vector2(0, -1)) > 0.6:
        found_floor = true
```

**动画状态机：** 根据速度和地面状态切换动画：
- idle / idle_weapon / run / run_weapon
- jumping / jumping_weapon / falling / falling_weapon

**射击系统：**
```gdscript
func _shot_bullet():
    var bullet := BULLET_SCENE.instantiate() as RigidBody2D
    bullet.linear_velocity = Vector2(400.0 * speed_scale, -40)
    add_collision_exception_with(bullet)  # 避免子弹与玩家碰撞
```

### `enemy/enemy.gd` — 敌人

```gdscript
enum State { WALKING, DYING }
```

- 左右巡逻，遇到墙壁或悬崖转向
- 被子弹击中后进入 DYING 状态，播放爆炸动画后销毁
- 使用 `RayCast2D` 检测悬崖

### `player/bullet.gd` — 子弹

- 继承 `RigidBody2D`，发射后自动飞行
- 击中敌人后调用 `disable()` 播放关闭动画

### `coin/coin.gd` — 金币

```gdscript
func _on_body_enter(body):
    if not taken and body is Player:
        $AnimationPlayer.play(&"taken")
```

## 5. 关键概念详解

### _integrate_forces() vs _physics_process()

`_integrate_forces()` 在物理引擎积分阶段调用，是修改 `RigidBody2D` 速度的正确位置。直接修改 `position` 会导致物理异常。

### 物理驱动角色的优势

- 自动与物理世界交互（跷跷板、可推动物体）
- 可以被其他物理对象推动（骑乘敌人）
- 更真实的物理表现

## 6. 场景树全景

```
Stage (Node2D)
├── Player (RigidBody2D)
│   ├── CollisionShape2D
│   ├── Sprite2D
│   │   └── Smoke (CPUParticles2D)
│   ├── AnimationPlayer
│   ├── BulletShoot (Marker2D)
│   ├── SoundJump
│   └── SoundShoot
├── Ground (StaticBody2D)
├── SeeSaw (RigidBody2D)
├── Enemy (RigidBody2D)
└── Coin (Area2D)
```

## 7. 如何扩展

- 添加更多武器类型（散弹、连发等）
- 实现敌人 AI（追踪玩家、跳跃等）
- 添加物理机关（移动平台、弹射器）
