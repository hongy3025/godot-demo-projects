# Loading in a Thread - 源代码导读

> 本文档面向 Godot 新手，剖析使用 Thread 类在独立线程中加载资源的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Loading in a Thread**（Godot 4.6）

演示使用 `Thread` 类在独立线程中加载图像，避免阻塞主线程。

---

## 2. 快速上手

运行 `thread.tscn`。点击"Load"按钮，观察控制台输出，图像加载完成后显示。

---

## 3. 核心架构

```
thread.tscn  ← 主场景
  └── thread.gd  ← 线程加载逻辑
```

---

## 4. 文件逐层导读

### `thread.gd` — 线程加载 ⭐

**`_on_load_pressed()` 启动线程：**
```gdscript
func _on_load_pressed() -> void:
    if is_instance_valid(thread) and thread.is_started():
        thread.wait_to_finish()  # 等待前一个线程完成
    thread = Thread.new()
    thread.start(_bg_load.bind("res://mona.png"))  # 启动线程
```

**`_bg_load(path)` 后台加载函数：**
```gdscript
func _bg_load(path: String) -> Texture2D:
    var tex := load(path)       # 在线程中加载资源
    _bg_load_done.call_deferred()  # 通知主线程
    return tex
```

**`_bg_load_done()` 主线程回调：**
```gdscript
func _bg_load_done() -> void:
    var tex: Texture2D = thread.wait_to_finish()  # 获取返回值
    $TextureRect.texture = tex  # 设置纹理
    thread = null  # 释放线程引用
```

**`_exit_tree()` 安全清理：**
```gdscript
func _exit_tree() -> void:
    if is_instance_valid(thread) and thread.is_started():
        thread.wait_to_finish()
        thread = null
```

---

## 5. 关键概念详解

### 5.1 线程安全原则

- **不要**从子线程直接操作场景树节点
- 使用 `call_deferred()` 在主线程执行节点操作
- 线程函数返回结果，主线程通过 `wait_to_finish()` 获取

### 5.2 Thread 生命周期

```
创建: Thread.new()
启动: thread.start(function, args...)
等待: thread.wait_to_finish()  # 阻塞直到完成
清理: thread = null
```

### 5.3 为什么需要 _exit_tree()

- 如果场景被移除而线程仍在运行，可能导致崩溃
- 始终在 `_exit_tree()` 中等待线程完成

### 5.4 Thread 与 ResourceLoader 对比

| 方式 | 复杂度 | 控制力 | 适用场景 |
|------|--------|--------|----------|
| `ResourceLoader.load_threaded_*` | 低 | 中 | 简单资源加载 |
| 手动 Thread（本项目） | 高 | 高 | 自定义加载逻辑 |
