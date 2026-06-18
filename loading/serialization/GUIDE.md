# Saving and Loading (Serialization) - 源代码导读

> 本文档面向 Godot 新手，剖析游戏存档的两种序列化方式：ConfigFile 和 JSON。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Saving and Loading (Serialization)**（Godot 4.6）

演示使用 ConfigFile 和 JSON 两种格式保存和加载游戏状态（玩家位置、血量、敌人位置）。

---

## 2. 快速上手

运行 `save_load.tscn`。用 WASD 移动玩家，点击 Save 存档，Load 读档。

---

## 3. 核心架构

```
save_load.tscn  ← 主场景
├── gui.gd  ← 界面控制
├── player.gd  ← 玩家逻辑（CharacterBody2D）
├── enemy.gd  ← 敌人逻辑
├── save_load_json.gd  ← JSON 序列化
└── save_load_config_file.gd  ← ConfigFile 序列化
```

---

## 4. 文件逐层导读

### `save_load_json.gd` — JSON 序列化 ⭐

**`save_game()`：**
```gdscript
var save_dict := {
    player = {
        position = var_to_str(player.position),  # Vector2 → String
        health = var_to_str(player.health),
        rotation = var_to_str(player.sprite.rotation),
    },
    enemies = [],
}
for enemy in get_tree().get_nodes_in_group(&"enemy"):
    save_dict.enemies.push_back({ position = var_to_str(enemy.position) })
file.store_line(JSON.stringify(save_dict))
```

**`load_game()`：**
```gdscript
json.parse(file.get_line())
var save_dict := json.get_data() as Dictionary
player.position = str_to_var(save_dict.player.position)
# 删除旧敌人，重新实例化
for enemy_config in save_dict.enemies:
    var enemy := preload("res://enemy.tscn").instantiate()
    enemy.position = str_to_var(enemy_config.position)
    game.add_child(enemy)
```

### `save_load_config_file.gd` — ConfigFile 序列化 ⭐

**`save_game()`：**
```gdscript
var config := ConfigFile.new()
config.set_value("player", "position", player.position)  # 原生支持 Vector2
config.set_value("player", "health", player.health)
config.save(SAVE_PATH)
```

**`load_game()`：**
```gdscript
config.load(SAVE_PATH)
player.position = config.get_value("player", "position")  # 直接还原
```

### `player.gd` — 玩家

```gdscript
class_name Player
extends CharacterBody2D

var health := 100.0  # setter 中更新血条
```

### `enemy.gd` — 敌人

```gdscript
class_name Enemy
extends Node2D

func _process(delta: float) -> void:
    if is_instance_valid(attacking):
        attacking.health -= delta * DAMAGE_PER_SECOND
    position.x += MOVEMENT_SPEED * delta
```

### `gui.gd` — 界面

- 检查存档文件是否存在，禁用/启用加载按钮
- `_on_open_user_data_folder_pressed()` 打开用户数据目录

---

## 5. 关键概念详解

### 5.1 ConfigFile vs JSON

| 特性 | ConfigFile | JSON |
|------|------------|------|
| 类型支持 | 原生支持 Vector2 等 | 需 `var_to_str` / `str_to_var` |
| 可读性 | INI 格式，可读 | 紧凑，可读 |
| 文件扩展名 | `.ini` | `.json` |
| 适用场景 | Godot 内部配置 | 跨平台数据交换 |

### 5.2 序列化关键函数

| 函数 | 用途 |
|------|------|
| `var_to_str(variant)` | 任意类型 → String |
| `str_to_var(string)` | String → 任意类型 |
| `JSON.stringify(data)` | Dictionary → JSON 字符串 |
| `JSON.parse(string)` | JSON 字符串 → Dictionary |

### 5.3 敌人管理

- 敌人通过 `add_to_group("enemy")` 分组
- 加载时用 `call_group("enemy", "queue_free")` 清空旧敌人
- 用 `preload("res://enemy.tscn").instantiate()` 重新实例化
