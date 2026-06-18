# 自定义日志 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中实现自定义日志记录器并在游戏内控制台显示日志"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的自定义日志演示项目。核心思路是：

> **通过继承 `Logger` 类创建自定义日志记录器，与引擎内置日志系统并行运行，在游戏内 RichTextLabel 中实时显示所有日志输出。**

项目包含两种日志显示方式：
- **自定义日志 UI（自动加载）：** 将引擎所有日志消息捕获并显示在游戏内控制台
- **主场景 UI：** 提供按钮触发各种类型的日志输出（print、printerr、push_warning、push_error 等）

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `main.tscn`。

### 2.2 操作说明

| 按钮 | 功能 |
|------|------|
| Print Message | 输出普通日志 |
| Print Message (Raw) | 输出原始日志（无换行） |
| Print Message (stderr) | 输出到标准错误 |
| Print Warning | 输出警告 |
| Print Error | 输出错误 |
| Open Logs Folder | 打开日志文件目录 |
| Crash Engine | 主动崩溃引擎（用于测试） |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          游戏内控制台显示层             │
│  CustomLoggerUI (RichTextLabel)       │
├──────────────────────────────────────┤
│          自定义日志记录器              │
│  CustomLogger (继承 Logger)           │
│  _log_message() / _log_error()        │
├──────────────────────────────────────┤
│          Godot 引擎日志系统            │
│  OS.add_logger() / OS.remove_logger() │
│  print() / push_error() / 等          │
└──────────────────────────────────────┘
```

### 3.2 自动加载配置

在 `project.godot` 中：
```ini
[autoload]
CustomLoggerUI="*res://custom_logger_ui.tscn"
```

`CustomLoggerUI` 被设置为自动加载（Singleton），在游戏启动时立即注册自定义日志记录器。

---

## 4. 文件逐层导读

### 4.1 `custom_logger_ui.gd` — 自定义日志记录器 ⭐

**地位：** 项目的核心。作为自动加载的单例，在游戏启动时注册自定义日志记录器。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_init()` | 在节点初始化时调用 `OS.add_logger(logger)` 注册自定义日志记录器 |
| `_exit_tree()` | 在节点销毁时调用 `OS.remove_logger(logger)` 移除日志记录器 |

**内部类 `CustomLogger`（继承 `Logger`）：**

```gdscript
class CustomLogger extends Logger:
    func _log_message(message: String, _error: bool) -> void:
        CustomLoggerUI.get_node(^"Panel/RichTextLabel").call_deferred(&"append_text", message)
```

- `_log_message()`：处理普通日志消息，使用 `call_deferred()` 确保线程安全
- `_log_error()`：处理错误/警告/脚本错误/着色器错误，添加颜色标记和调用堆栈

**错误类型颜色标记：**

| 类型 | 颜色 | 前缀 |
|------|------|------|
| ERROR | `#f54` 红色 | `ERROR:` |
| WARNING | `#fd4` 黄色 | `WARNING:` |
| SCRIPT ERROR | `#f4f` 紫色 | `SCRIPT ERROR:` |
| SHADER ERROR | `#4bf` 蓝色 | `SHADER ERROR:` |

> **新手提示：** `call_deferred()` 确保对节点的操作在主线程执行，因为自定义日志记录器可能从非主线程被调用。

### 4.2 `main.gd` — 主场景逻辑

**职责：** 提供按钮触发各种类型的日志输出，演示不同日志 API 的效果。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 启动时输出示例日志（print、push_error、push_warning、printerr、printraw） |
| `_on_print_message_pressed()` | 调用 `print()` 输出普通日志 |
| `_on_print_message_raw_pressed()` | 调用 `printraw()` 输出原始日志 |
| `_on_print_message_stderr_pressed()` | 调用 `printerr()` 输出到标准错误 |
| `_on_print_warning_pressed()` | 调用 `push_warning()` 输出警告 |
| `_on_print_error_pressed()` | 调用 `push_error()` 输出错误 |
| `_on_open_logs_folder_pressed()` | 打开引擎日志文件所在目录 |
| `_on_crash_engine_pressed()` | 调用 `OS.crash()` 主动崩溃引擎 |

---

## 5. 关键概念详解

### 5.1 自定义日志记录器的工作原理

```
引擎输出日志
    ↓
内置日志系统（文件 + 控制台）
    ↓
OS.add_logger() → 注册自定义 Logger
    ↓
_log_message() / _log_error() 被回调
    ↓
call_deferred("append_text", message)
    ↓
RichTextLabel 显示格式化日志
```

### 5.2 线程安全

自定义日志记录器**必须**是线程安全的，因为它们可能从非主线程被调用。项目使用 `call_deferred()` 将对节点的操作推迟到主线程执行，避免线程冲突。

### 5.3 注册时机

使用 `_init()` 而不是 `_ready()` 注册日志记录器，确保尽可能早地捕获日志消息。但即使如此，引擎自身的初始化消息也无法被捕获。

### 5.4 移除日志记录器

项目退出时自动移除日志记录器。如果需要提前移除，可调用 `OS.remove_logger()`，这也可以避免退出时的对象泄漏警告。

---

## 6. 场景树全景

### 6.1 主场景 `main.tscn`

```
Main (Control)
├── VBoxContainer
│   ├── FlushStdoutOnPrint (Label)      ← 显示 stdout 刷新设置
│   ├── PrintMessage (Button)
│   ├── PrintMessageRaw (Button)
│   ├── PrintMessageStderr (Button)
│   ├── PrintWarning (Button)
│   ├── PrintError (Button)
│   ├── OpenLogsFolder (Button)
│   └── CrashEngine (Button)
```

### 6.2 自动加载场景 `custom_logger_ui.tscn`

```
CustomLoggerUI (RichTextLabel)          ← 自动加载，始终存在
└── Panel
    └── RichTextLabel                   ← 显示所有日志消息
```

---

## 7. 如何扩展

### 7.1 自定义日志格式

修改 `CustomLogger._log_message()` 或 `_log_error()` 中的格式化逻辑：

```gdscript
func _log_message(message: String, _error: bool) -> void:
    var formatted = "[color=#fff]%s[/color]" % message
    CustomLoggerUI.get_node(^"Panel/RichTextLabel").call_deferred(&"append_text", formatted)
```

### 7.2 添加日志过滤

在 `_log_message()` 中添加条件判断，只显示特定类型的日志：

```gdscript
func _log_message(message: String, _error: bool) -> void:
    if message.contains("DEBUG"):
        return  # 过滤调试信息
    # ...
```

### 7.3 日志持久化

除了在游戏内显示，还可以将日志写入自定义文件：

```gdscript
func _log_message(message: String, _error: bool) -> void:
    var file = FileAccess.open("user://custom_log.txt", FileAccess.WRITE_READ)
    file.seek_end()
    file.store_line(message)
```

---

## 推荐阅读路径

如果你是 GDScript 新手，建议按以下顺序阅读源码：

1. **`custom_logger_ui.gd`** — 理解自定义日志记录器的核心实现
2. **`main.gd`** — 看各种日志 API 的使用方式
3. **`project.godot`** — 理解自动加载配置
