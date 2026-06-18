# Grid-based Pathfinding with AStarGrid2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 `AStarGrid2D` 在网格地图上实现寻路，并结合转向行为（Steering Behaviors）实现平滑移动。左键移动到目标点，右键瞬移。

## 2. 快速上手

运行 `game.tscn`，左键点击目标位置，角色沿路径移动；右键点击直接瞬移。

## 3. 核心架构

```
game.tscn
├── TileMapLayer           ← 瓦片地图（同时也是 AStarGrid2D 管理器）
└── Character (Node2D)     ← 角色
```

## 4. 文件逐层导读

### `pathfind_astar.gd` — A* 寻路核心 ⭐

```gdscript
var _astar := AStarGrid2D.new()

func _ready():
    _astar.region = Rect2i(0, 0, 18, 10)
    _astar.cell_size = CELL_SIZE
    _astar.offset = CELL_SIZE * 0.5
    _astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    _astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    _astar.update()

    for pos in get_used_cells():
        _astar.set_point_solid(pos)  # 标记障碍物
```

**关键方法：**
- `find_path()`：计算路径，返回 `PackedVector2Array`
- `is_point_walkable()`：检查某格是否可行走
- `clear_path()`：清除路径和标记
- `_draw()`：绘制路径线条和节点

**路径可视化：** 在 `_draw()` 中用 `draw_line()` 和 `draw_circle()` 绘制路径。

### `character.gd` — 角色控制器

**状态机：**
```gdscript
enum State { IDLE, FOLLOW }
```

**转向行为（Steering Behavior）：**
```gdscript
func _move_to(local_position):
    var desired_velocity = (local_position - position).normalized() * speed
    var steering = desired_velocity - _velocity
    _velocity += steering / MASS
    position += _velocity * get_physics_process_delta_time()
    rotation = _velocity.angle()
    return position.distance_to(local_position) < ARRIVE_DISTANCE
```

- `MASS = 10`：质量越大，转向越慢
- `ARRIVE_DISTANCE = 10`：到达判定距离
- 角色朝向随速度方向旋转

## 5. 关键概念详解

### AStarGrid2D

专为网格地图设计的 A* 寻路类：
- `region`：定义网格区域
- `cell_size`：单元格大小
- `set_point_solid()`：标记障碍物
- `get_point_path()`：获取路径点列表
- `HEURISTIC_MANHATTAN`：曼哈顿距离启发函数（不允许对角移动）

### 转向行为

与直接寻路不同，转向行为让角色平滑地沿路径移动，而不是"卡"在网格点上。通过质量（MASS）控制转向的平滑度。

## 6. 场景树全景

```
Game (Node2D)
├── TileMapLayer (PathFindAStar)
└── Character (Node2D)
    └── Sprite2D
```

## 7. 如何扩展

- 修改 `DIAGONAL_MODE` 允许对角移动
- 添加动态障碍物，运行时调用 `set_point_solid()`
- 使用 `get_id_path()` 获取网格坐标路径而非世界坐标路径
