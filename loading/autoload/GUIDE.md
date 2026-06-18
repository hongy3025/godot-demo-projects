# Autoload (Singletons) - 源代码导读

> 本文档面向 Godot 新手，剖析自动加载（单例）在场景切换中的使用方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Autoload (Singletons)**（Godot 4.6）

演示如何使用自动加载（Autoload）在场景之间切换，不依赖 `SceneTree.change_scene_to_file()` 等内置方法。

---

## 2. 快速上手

运行 `scene_a.tscn`。点击按钮切换到场景 B，再点回来。

---

## 3. 核心架构

```
global.gd  ← 自动加载单例，管理场景切换
scene_a.tscn → scene_a.gd  ← 场景 A
scene_b.tscn → scene_b.gd  ← 场景 B
```

---

## 4. 文件逐层导读

### `global.gd` — 自动加载单例 ⭐

**`goto_scene(path)` 入口：**
```gdscript
func goto_scene(path: String) -> void:
    _deferred_goto_scene.call_deferred(path)
```
使用 `call_deferred()` 延迟执行，避免在信号回调中直接删除当前场景导致崩溃。

**`_deferred_goto_scene(path)` 实际切换：**
```gdscript
func _deferred_goto_scene(path: String) -> void:
    get_tree().current_scene.free()          # 释放当前场景
    var packed_scene: PackedScene = ResourceLoader.load(path)
    var instanced_scene := packed_scene.instantiate()
    get_tree().root.add_child(instanced_scene)  # 添加到根节点
    get_tree().current_scene = instanced_scene  # 设为当前场景
```

### `scene_a.gd` / `scene_b.gd` — 场景脚本

```gdscript
func _on_goto_scene_pressed() -> void:
    global.goto_scene("res://scene_b.tscn")  # 通过全局单例切换
```

---

## 5. 关键概念详解

### 5.1 为什么用 call_deferred()

在信号回调或函数执行过程中删除当前场景节点可能导致：
- 崩溃（访问已释放的内存）
- 未定义行为

`call_deferred()` 将操作推迟到当前帧处理完成后执行。

### 5.2 自动加载配置

`project.godot` 中：
```ini
[autoload]
global="*res://global.gd"
```
`*` 表示自动创建实例，全局可通过 `global` 访问。

### 5.3 手动场景切换 vs 内置方法

| 方式 | 优点 | 缺点 |
|------|------|------|
| `change_scene_to_file()` | 一行代码 | 控制力弱 |
| 手动（本项目） | 完全控制加载过程 | 代码较多 |
