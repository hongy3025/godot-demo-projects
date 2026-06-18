# Scene Instancing Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 Godot 的场景实例化（Scene Instancing）机制。点击鼠标左键在点击位置生成一个物理球体，球体受重力影响下落并与地面碰撞。

## 2. 快速上手

运行 `scene_instancing.tscn`，在屏幕任意位置点击左键生成球体。

## 3. 核心架构

```
scene_instancing.tscn
├── BallFactory (Node2D)   ← 球体生成器
├── Ground (StaticBody2D)  ← 地面
└── Walls (StaticBody2D)   ← 墙壁
```

球体本身是一个独立的 `ball.tscn` 场景。

## 4. 文件逐层导读

### `ball_factory.gd` — 球体工厂

```gdscript
@export var ball_scene: PackedScene = preload("res://ball.tscn")

func _unhandled_input(input_event):
    if input_event is InputEventMouseButton and input_event.is_pressed():
        if input_event.button_index == MOUSE_BUTTON_LEFT:
            spawn(get_global_mouse_position())

func spawn(spawn_global_position):
    var instance = ball_scene.instantiate()
    instance.global_position = spawn_global_position
    add_child(instance)
```

**核心逻辑：** 预加载 `PackedScene`，每次点击调用 `instantiate()` 创建新实例，添加到场景树。

### `ball.tscn` — 球体场景

- `RigidBody2D`：物理驱动，自动受重力和碰撞影响
- `CollisionShape2D`：圆形碰撞形状
- `Sprite2D`：球体外观

## 5. 关键概念详解

### PackedScene.instantiate()

`PackedScene` 是预加载的场景模板。`instantiate()` 创建该模板的一个副本，效率高于从文件加载。适合需要大量重复对象的场景。

### 场景实例化的性能考量

- 每个实例是一个完整的节点树，有完整的生命周期
- 适合几十到几百个对象
- 对于数千个对象，应考虑使用 `PhysicsServer2D`（如 `bullet_shower` 项目）

## 6. 场景树全景

```
SceneInstancing (Node2D)
├── BallFactory (Node2D)
├── Ground (StaticBody2D)
│   └── CollisionShape2D
├── Walls (StaticBody2D)
│   └── CollisionShape2D
└── Ball (RigidBody2D) ×N  ← 动态生成
```

## 7. 如何扩展

- 修改 `ball.tscn` 更换球体外观或物理属性
- 添加球体销毁逻辑（离开屏幕时 `queue_free()`）
- 限制最大球体数量，超出时删除最早的球体
