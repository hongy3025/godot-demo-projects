# Dodge the Creeps - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

这是 Godot 官方教程"你的第一个 2D 游戏"的完整实现。玩家在屏幕中移动躲避从四周飞来的怪物，坚持时间越长得分越高。

## 2. 快速上手

运行 `main.tscn`，点击"Start"开始。WASD/方向键移动，躲避红色怪物。碰到怪物游戏结束。

## 3. 核心架构

```
main.tscn
├── Player (Area2D)          ← 玩家角色
├── MobTimer                 ← 怪物生成定时器
├── ScoreTimer               ← 计分定时器
├── StartTimer               ← 开始倒计时
├── MobPath (Path2D)         ← 怪物生成路径
│   └── MobSpawnLocation     ← 随机生成点
├── HUD (CanvasLayer)        ← UI 层
├── Music (AudioStreamPlayer)
└── DeathSound (AudioStreamPlayer)
```

## 4. 文件逐层导读

### `main.gd` — 游戏主控 ⭐

**职责：** 管理游戏生命周期（开始、进行、结束）。

```gdscript
func new_game():
    get_tree().call_group(&"mobs", &"queue_free")  # 清除旧怪物
    score = 0
    $Player.start($StartPosition.position)
    $StartTimer.start()
```

**怪物生成逻辑：**
1. `MobTimer` 超时 → 从 `MobPath` 随机位置生成怪物
2. 方向垂直于路径切线 + 随机偏移（±45°）
3. 速度 150~250，方向随机旋转

### `player.gd` — 玩家控制

```gdscript
extends Area2D
signal hit
```

- `_process(delta)` 中读取 WASD 输入，计算速度向量
- 位置用 `clamp()` 限制在屏幕内
- 碰撞后发射 `hit` 信号，隐藏玩家并禁用碰撞体

### `mob.gd` — 怪物

```gdscript
extends RigidBody2D
```

- `_ready()` 中随机选择怪物外观（3 种动画）
- 离开屏幕时自动 `queue_free()`

### `hud.gd` — 界面

```gdscript
extends CanvasLayer
signal start_game
```

- 显示/隐藏消息文本、分数、开始按钮
- 使用 `await` 实现时序控制（显示"Game Over"→等待→显示按钮）

## 5. 关键概念详解

### Area2D 碰撞检测

玩家使用 `Area2D`（而非 `CharacterBody2D`），因为只需要检测重叠而不需要物理响应。`body_entered` 信号在 RigidBody2D 进入时触发。

### 信号通信

```
Player.hit → Main.game_over() → HUD.show_game_over()
HUD.start_game → Main.new_game()
```

## 6. 场景树全景

```
Main (Node)
├── Player (Area2D)
│   ├── CollisionShape2D
│   ├── AnimatedSprite2D
│   └── Trail (Sprite2D)
├── StartPosition (Marker2D)
├── MobPath (Path2D)
│   └── MobSpawnLocation (PathFollow2D)
├── MobTimer (Timer)
├── ScoreTimer (Timer)
├── StartTimer (Timer)
├── HUD (CanvasLayer)
│   ├── ScoreLabel
│   ├── MessageLabel
│   ├── MessageTimer
│   └── StartButton
├── Music
└── DeathSound
```

## 7. 如何扩展

- 增加怪物类型：在 `mob.gd` 的 `mob_types` 数组中添加新动画名
- 增加道具系统：创建新的 `Area2D` 场景，用信号与 `Main` 通信
- 增加难度曲线：在 `_on_MobTimer_timeout()` 中逐渐缩短 `wait_time`
