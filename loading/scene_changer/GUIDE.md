# Scene Changer - 源代码导读

> 本文档面向 Godot 新手，剖析 SceneTree 场景切换功能的两种方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Scene Changer**（Godot 4.6）

演示使用 `SceneTree` 的两种方法在两个场景之间切换。

---

## 2. 快速上手

运行 `scene_a.tscn`。点击按钮切换到场景 B，再点回来。

---

## 3. 核心架构

```
scene_a.tscn → scene_a.gd  ← 场景 A（使用 change_scene_to_file）
scene_b.tscn → scene_b.gd  ← 场景 B（使用 change_scene_to_packed）
```

---

## 4. 文件逐层导读

### `scene_a.gd` — 按文件路径切换

```gdscript
extends Panel

func _on_goto_scene_pressed() -> void:
    get_tree().change_scene_to_file("res://scene_b.tscn")
```

### `scene_b.gd` — 按 PackedScene 切换

```gdscript
extends Panel

func _on_goto_scene_pressed() -> void:
    var scene: PackedScene = load("res://scene_a.tscn")
    get_tree().change_scene_to_packed(scene)
```

---

## 5. 关键概念详解

### 5.1 两种切换方式对比

| 方法 | 参数 | 优点 | 缺点 |
|------|------|------|------|
| `change_scene_to_file(path)` | 文件路径字符串 | 简单直接 | 每次从磁盘加载 |
| `change_scene_to_packed(scene)` | PackedScene 对象 | 可预加载、线程加载 | 需要先 load() |

### 5.2 使用场景

- `change_scene_to_file`：简单项目，快速开发
- `change_scene_to_packed`：需要预加载、进度条、线程加载的复杂项目

### 5.3 注意事项

- 两种方法都会释放当前场景树
- 切换后原场景的状态丢失
- 需要跨场景持久化的数据应使用自动加载（Autoload）
