# Hierarchical Finite State Machine - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何在 Godot 中实现分层有限状态机（HFSM）和推下自动机（Pushdown Automaton）。玩家角色具有待机、移动、跳跃、攻击、眩晕、死亡等状态，状态之间可以嵌套和堆叠。

## 2. 快速上手

运行 `Demo.tscn`，WASD 移动，空格跳跃，F 攻击，R 射击，X 模拟受伤。注意左上角的状态栈显示。

## 3. 核心架构

```
state_machine/
├── state.gd              ← 状态基类接口
└── state_machine.gd      ← 状态机基类

player/
├── player_controller.gd  ← 玩家物理体
├── player_state.gd       ← 玩家状态常量
├── player_state_machine.gd ← 玩家状态机
├── states/
│   ├── motion/
│   │   ├── motion.gd
│   │   ├── on_ground/
│   │   │   ├── on_ground.gd
│   │   │   ├── idle.gd
│   │   │   └── move.gd
│   │   └── in_air/
│   │       └── jump.gd
│   ├── combat/
│   │   ├── attack.gd
│   │   └── stagger.gd
│   └── die.gd
├── weapon/
│   ├── sword.gd
│   └── weapon_pivot.gd
└── bullet/
    ├── bullet_spawner.gd
    └── bullet.gd
```

## 4. 文件逐层导读

### `state_machine/state.gd` — 状态接口

```gdscript
extends Node
signal finished(next_state_name: StringName)

func enter(): pass
func exit(): pass
func handle_input(_input_event): pass
func update(_delta): pass
func _on_animation_finished(_anim_name): pass
```

所有状态节点必须实现这些方法。`finished` 信号通知状态机切换状态。

### `state_machine/state_machine.gd` — 状态机核心 ⭐

**关键机制：**

```gdscript
var states_stack := []  # 推下自动机栈
var current_state: Node = null
```

- `_enter_tree()` 中连接所有子状态的 `finished` 信号
- `_change_state(state_name)` 处理状态切换
- 支持"推入"模式（跳跃/攻击/眩晕时压入新状态，结束后弹出回到之前状态）
- `state_name == "previous"` 时从栈中弹出

### `player/player_state_machine.gd` — 玩家状态机

```gdscript
func _change_state(state_name):
    if state_name in [stagger, jump, attack]:
        states_stack.push_front(states_map[state_name])  # 推入栈
    if state_name == jump and current_state == move:
        jump.initialize(move.speed, move.velocity)  # 传递移动速度
```

**推下自动机行为：** 攻击/跳跃/眩晕时，当前状态被压入栈，结束后弹出恢复之前状态。

### 各状态脚本

| 文件 | 行为 |
|------|------|
| `idle.gd` | 待机，检测移动输入切换到 move |
| `move.gd` | 移动，处理 WASD 和跑步 |
| `jump.gd` | 跳跃，继承移动速度 |
| `attack.gd` | 攻击动画，结束后返回之前状态 |
| `stagger.gd` | 受击后退，结束后返回之前状态 |
| `die.gd` | 死亡，禁用输入和物理 |

## 5. 关键概念详解

### 分层状态机（HFSM）

```
Motion (基类)
├── OnGround (基类)
│   ├── Idle
│   └── Move
└── InAir (基类)
    └── Jump
```

子状态继承父状态的行为，`on_ground.gd` 处理地面通用逻辑，`idle` 和 `move` 只处理各自特有的输入。

### 推下自动机（Pushdown Automaton）

```
状态栈：[Idle]
按攻击 → [Idle, Attack]  ← 压入
攻击结束 → [Idle]         ← 弹出
```

用于"可中断"的状态，如攻击可以被眩晕中断，眩晕结束后回到攻击。

## 6. 场景树全景

```
Player (CharacterBody2D)
├── CollisionPolygon2D
├── Sprite2D
├── AnimationPlayer
├── PlayerStateMachine (StateMachine)
│   ├── Motion (Motion)
│   │   ├── OnGround (OnGround)
│   │   │   ├── Idle
│   │   │   └── Move
│   │   └── InAir (InAir)
│   │       └── Jump
│   ├── Combat
│   │   ├── Attack
│   │   └── Stagger
│   └── Die
├── WeaponPivot
│   └── Sword
├── BulletSpawner
└── Health
```

## 7. 如何扩展

- 添加新状态：创建继承 `State.gd` 的脚本，添加到场景树中
- 在 `player_state_machine.gd` 的 `states_map` 中注册新状态
- 在状态中发射 `finished.emit("state_name")` 触发切换
