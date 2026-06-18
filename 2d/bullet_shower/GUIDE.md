# Bullet Shower - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

这是一个性能演示项目，展示如何使用 Godot 底层 `PhysicsServer2D` 和 `RenderingServer` 高效管理大量对象（500 颗子弹），而不使用传统节点实例化方式。

**核心思想：** 用 RID（资源 ID）直接操作物理和渲染服务，避免创建 500 个节点的开销。

## 2. 快速上手

运行 `shower.tscn`，鼠标控制玩家移动，子弹从右向左飞过。当子弹碰到玩家时，玩家表情变为悲伤。

## 3. 核心架构

```
shower.tscn
├── Player (Node2D)         ← 玩家，跟随鼠标
│   ├── CollisionShape2D    ← 碰撞检测区域
│   └── AnimatedSprite2D    ← 表情动画
└── Bullets (Node2D)        ← 子弹管理器，无子节点
```

**关键差异：** 500 颗子弹没有创建 500 个节点，而是用 `bullets.gd` 中的数组和 RID 统一管理。

## 4. 文件逐层导读

### `bullets.gd` — 子弹管理器 ⭐

**核心数据结构：**
```gdscript
class Bullet:
    var position := Vector2()
    var speed := 1.0
    var body := RID()  # 物理体的 RID
```

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 创建 500 颗子弹，每颗通过 `PhysicsServer2D.body_create()` 创建物理体 |
| `_physics_process(delta)` | 每帧更新子弹位置（左移），用 `body_set_state` 同步到物理服务 |
| `_draw()` | 一次性绘制所有子弹的纹理 |
| `_exit_tree()` | 清理所有 RID，避免控制台报错 |

**性能优化技巧：**
- `body_set_collision_mask(bullet.body, 0)` — 子弹之间不互相碰撞
- 所有子弹共用同一个 `shape` RID（圆形碰撞形状）
- 批量绘制而非每个子弹单独绘制

### `player.gd` — 玩家控制器

```gdscript
func _input(input_event):
    if input_event is InputEventMouseMotion:
        position = input_event.position - Vector2(0, 16)
```

- 隐藏鼠标光标，玩家跟随鼠标移动
- 通过 `body_shape_entered`/`body_shape_exited` 信号统计碰撞次数
- 碰撞数 > 0 时切换为悲伤表情

## 5. 关键概念详解

### RID（Resource ID）

RID 是 Godot 底层服务的"句柄"。相比节点：
- 创建快得多（无需场景树初始化）
- 内存占用小
- 需要手动管理生命周期（`free_rid`）

### 底层服务 vs 节点

| 方式 | 500 节点 | 500 RID |
|------|----------|---------|
| 内存 | 高 | 低 |
| 创建速度 | 慢 | 快 |
| 易用性 | 高 | 低 |
| 适用场景 | < 100 对象 | > 1000 对象 |

## 6. 场景树全景

```
Shower (Node2D)
├── Player (Node2D)
│   ├── CollisionShape2D
│   └── AnimatedSprite2D
└── Bullets (Node2D)   ← 无子节点，500 颗子弹由脚本管理
```

## 7. 如何扩展

- 调整 `BULLET_COUNT` 常量测试性能上限
- 修改 `SPEED_MIN`/`SPEED_MAX` 改变子弹速度范围
- 在 `_draw()` 中为子弹添加颜色变化或大小变化
