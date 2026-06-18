# JRPG Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

一个 JRPG 风格的小型演示，包含网格移动、对话系统和回合制战斗系统。玩家在网格地图上移动，与 NPC 对话触发战斗。

## 2. 快速上手

运行 `game.tscn`，WASD 网格移动，走到 NPC 面前触发对话，对话结束后进入战斗。战斗中点击按钮选择行动。

## 3. 核心架构

```
src/
├── game.gd                    ← 游戏主控
├── grid_movement/
│   ├── grid/grid.gd           ← 网格系统
│   └── pawns/
│       ├── pawn.gd            ← 棋子基类
│       ├── walker.gd          ← 可移动棋子
│       ├── player.gd          ← 玩家
│       └── opponent.gd        ← 对手 NPC
├── dialogue/
│   ├── dialogue_player/       ← 对话播放器
│   └── interface/             ← 对话 UI
└── combat/
    ├── combat.gd              ← 战斗系统
    ├── turn_queue.gd          ← 回合队列
    ├── combatants/            ← 战斗角色
    └── interface/             ← 战斗 UI
```

## 4. 文件逐层导读

### `game.gd` — 游戏主控 ⭐

**场景切换：** 探索模式和战斗模式之间切换，使用淡入淡出动画。

```gdscript
func start_combat(combat_actors):
    $AnimationPlayer.play(&"fade_to_black")
    await $AnimationPlayer.animation_finished
    remove_child($Exploration)
    add_child(combat_screen)
    combat_screen.initialize(combat_actors)
```

**战斗结果处理：** 根据胜负播放不同的对话。

### `grid_movement/grid/grid.gd` — 网格系统

```gdscript
extends TileMapLayer

enum CellType { ACTOR, OBSTACLE, OBJECT }

func request_move(pawn, direction):
    var cell_start := local_to_map(pawn.position)
    var cell_target := cell_start + direction
    var cell_tile_id := get_cell_source_id(cell_target)
    match cell_tile_id:
        -1:  # 空格 → 移动
            set_cell(cell_target, CellType.ACTOR, Vector2i.ZERO)
            set_cell(cell_start, -1, Vector2i.ZERO)
            return map_to_local(cell_target)
        CellType.OBJECT, CellType.ACTOR:  # 有物体 → 触发对话
            # 触发对话...
```

- 使用 `TileMapLayer` 的 `local_to_map()`/`map_to_local()` 实现网格坐标转换
- 移动时更新 TileMap 上的标记（清除旧位置，设置新位置）

### `grid_movement/pawns/player.gd` — 玩家移动

```gdscript
func _process(_delta):
    var input_direction := get_input_direction()
    input_direction = input_direction.round()  # 网格对齐
    if input_direction.is_zero_approx():
        return
    var target_position := grid.request_move(self, input_direction)
    if target_position:
        move_to(target_position)
    elif active:
        bump()  # 撞墙动画
```

### `combat/combat.gd` — 战斗系统

```gdscript
signal combat_finished(winner, loser)

func initialize(combat_combatants):
    for combatant_scene in combat_combatants:
        var combatant := combatant_scene.instantiate()
        $Combatants.add_combatant(combatant)
        combatant.get_node("Health").dead.connect(_on_combatant_death.bind(combatant))
```

## 5. 关键概念详解

### 网格移动

- 使用 `TileMapLayer` 作为网格数据结构
- 移动以整数网格为单位，通过 `round()` 对齐
- 碰撞检测通过检查 TileMap 上的 CellType 实现

### 探索 ↔ 战斗切换

游戏在两个模式间切换，使用 `AnimationPlayer` 的淡入淡出过渡。两个模式是互斥的（`remove_child`/`add_child`）。

### 对话系统

对话数据使用 JSON 文件定义。`DialoguePlayer` 节点解析 JSON 并驱动对话 UI。

## 6. 场景树全景

```
Game (Node)
├── Exploration (Node2D)
│   ├── Grid (TileMapLayer)
│   │   ├── Player (Pawn)
│   │   └── Opponent (Pawn)
│   │       └── DialoguePlayer
│   └── DialogueCanvas
│       └── DialogueUI
├── CombatScreen (Node2D)
│   ├── Combatants
│   ├── TurnQueue
│   └── CombatCanvas
│       └── UI
└── AnimationPlayer
```

## 7. 如何扩展

- 添加更多网格上的交互对象（宝箱、传送点等）
- 扩展战斗系统（添加技能、道具、魔法）
- 使用 JSON 定义更多对话分支
