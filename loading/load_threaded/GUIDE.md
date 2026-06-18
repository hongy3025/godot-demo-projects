# Threaded Loading - 源代码导读

> 本文档面向 Godot 新手，剖析 ResourceLoader 后台线程加载的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Threaded Loading**（Godot 4.6）

演示如何使用 `ResourceLoader` 的后台加载功能，在不阻塞主线程的情况下加载多个资源。

---

## 2. 快速上手

运行 `load_threaded.tscn`。点击"Start Loading"开始后台加载，然后逐个点击按钮显示已加载的图片。

---

## 3. 核心架构

```
load_threaded.tscn  ← 主场景
└── load_threaded.gd  ← 后台加载逻辑
paintings/  ← 6 幅名画图片资源
```

---

## 4. 文件逐层导读

### `load_threaded.gd` — 后台加载 ⭐

**`_on_start_loading_pressed()` 发起加载：**
```gdscript
ResourceLoader.load_threaded_request("res://paintings/painting_babel.jpg")
ResourceLoader.load_threaded_request("res://paintings/painting_las_meninas.png")
# ... 同时请求加载 6 幅图片
```
- 一次性发起多个加载请求
- 加载在后台线程进行，不阻塞界面
- 加载完成后启用对应的"获取"按钮

**获取已加载资源：**
```gdscript
func _on_babel_pressed() -> void:
    $Paintings/Babel.texture = ResourceLoader.load_threaded_get("res://paintings/painting_babel.jpg")
    $GetLoaded/Babel.disabled = true
```
- `load_threaded_get()` 获取已加载完成的资源
- 如果资源尚未加载完成，会阻塞直到完成

---

## 5. 关键概念详解

### 5.1 后台加载 API

| 方法 | 用途 |
|------|------|
| `load_threaded_request(path)` | 发起后台加载请求 |
| `load_threaded_get(path)` | 获取已加载的资源 |
| `load_threaded_get_status(path)` | 查询加载状态 |
| `load_threaded_get_progress(path)` | 查询加载进度 |

### 5.2 加载状态

| 状态 | 说明 |
|------|------|
| `THREAD_LOAD_INVALID_RESOURCE` | 无效资源 |
| `THREAD_LOAD_IN_PROGRESS` | 加载中 |
| `THREAD_LOAD_FAILED` | 加载失败 |
| `THREAD_LOAD_LOADED` | 加载完成 |

### 5.3 使用场景

- 关卡加载：后台加载资源，前台显示进度条
- 大型纹理/模型：避免卡顿
- 多个资源同时加载
