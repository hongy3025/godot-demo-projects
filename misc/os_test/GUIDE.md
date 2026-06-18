# 操作系统测试 - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中获取操作系统信息和与操作系统交互"。

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

这是一个 **Godot 4.6** 的操作系统测试项目。核心功能是：

> **通过 `OS`、`DisplayServer`、`Time`、`AudioServer`、`RenderingServer` 等 API，全面获取操作系统信息并与操作系统交互。**

功能覆盖：
- 音频设备信息
- 日期/时间
- 显示信息（DPI、分辨率、刷新率）
- 引擎版本和构建信息
- 环境变量
- 硬件信息（CPU、内存）
- 输入设备（触摸屏、MIDI）
- 本地化
- 软件信息（OS 名称、版本）
- 安全信息
- 系统目录
- 视频适配器信息
- C# 支持检测

---

## 2. 快速上手

### 2.1 运行项目

在 Godot 中打开 `project.godot`，直接运行主场景 `os_test.tscn`。

### 2.2 操作说明

| 按钮 | 功能 |
|------|------|
| Open Shell Web | 在浏览器中打开 URL |
| Open Shell Folder | 在文件管理器中打开用户目录 |
| Change Window Title | 修改窗口标题 |
| Change Window Icon | 修改窗口图标 |
| Move Window to Foreground | 5 秒后将窗口移到前台 |
| Request Attention | 5 秒后请求用户注意 |
| Vibrate Device Short/Long | 设备振动 |
| Add/Remove Global Menu Items | 添加/移除全局菜单 |
| Get/Set Clipboard | 获取/设置剪贴板 |
| Display Alert | 显示警告对话框 |
| Kill Current Process | 终止当前进程 |

---

## 3. 核心架构

### 3.1 架构分层

```
┌──────────────────────────────────────┐
│          信息显示层                   │
│  RichTextLabel (左侧信息面板)        │
├──────────────────────────────────────┤
│          信息收集层                   │
│  os_test.gd (OS/DisplayServer API)   │
├──────────────────────────────────────┤
│          操作执行层                   │
│  actions.gd (按钮交互)               │
├──────────────────────────────────────┤
│         Godot 系统 API 层            │
│  OS / DisplayServer / Time / ...     │
└──────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### 4.1 `os_test.gd` — 系统信息收集 ⭐

**地位：** 项目的核心，收集并显示所有操作系统信息。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 调用所有信息收集函数，填充左侧面板 |
| `add_header(header)` | 添加分类标题 |
| `add_line(key, value)` | 添加信息行（自动交替背景色） |
| `datetime_to_string(date)` | 格式化日期时间字典为字符串 |
| `scan_midi_inputs()` | 扫描连接的 MIDI 输入设备 |

**信息分类：**

| 分类 | 收集的信息 |
|------|-----------|
| Audio | 采样率、延迟、音频设备、MIDI 输入 |
| Date and time | 本地/UTC 时间、时区、UNIX 时间 |
| Display | 屏幕数量、DPI、分辨率、刷新率、安全区域 |
| Engine | 版本、架构、命令行参数、调试模式 |
| Environment | PATH 环境变量 |
| Hardware | 型号、处理器、唯一 ID |
| Input | 触摸屏、虚拟键盘 |
| Localization | 区域设置、语言 |
| Mobile | 已授予权限 |
| .NET (C#) | Mono 模块是否启用 |
| Software | OS 名称、版本、深色模式、系统字体 |
| Security | 沙箱状态、随机熵、CA 证书 |
| Engine directories | 用户数据、配置、缓存目录 |
| System directories | 桌面、文档、下载等系统目录 |
| Video | 显卡名称、厂商、驱动版本 |

**信息格式化：**

```gdscript
func add_line(key: String, value: Variant) -> void:
    line_count += 1
    rtl.append_text("{bgcolor}[color=#9df]{key}:[/color] {value}{bgcolor_end}\n".format({
            key = key,
            value = value,
            bgcolor = "[bgcolor=#8883]" if line_count % 2 == 0 else "",
            bgcolor_end = "[/bgcolor]" if line_count % 2 == 0 else "",
        }))
```

布尔值自动着色（true=绿色，false=红色），同时输出到终端。

### 4.2 `actions.gd` — 系统操作 ⭐

**地位：** 处理按钮点击触发的系统操作。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | Web 平台禁用不支持的按钮 |
| `_on_open_shell_web_pressed()` | 打开网页 |
| `_on_open_shell_folder_pressed()` | 打开文件管理器 |
| `_on_change_window_title_pressed()` | 修改窗口标题 |
| `_on_change_window_icon_pressed()` | 修改窗口图标 |
| `_on_move_window_to_foreground_pressed()` | 移到前台 |
| `_on_request_attention_pressed()` | 请求注意 |
| `_on_vibrate_device_short/long_pressed()` | 设备振动 |
| `_on_add/remove_global_menu_items_pressed()` | 全局菜单管理 |
| `_on_get/set_clipboard_pressed()` | 剪贴板操作 |
| `_on_display_alert_pressed()` | 显示警告 |
| `_on_kill_current_process_pressed()` | 终止进程 |

**平台兼容性处理：**

```gdscript
if OS.has_feature("web"):
    for button in [OpenShellFolder, MoveWindowToForeground, ...]:
        button.disabled = true
        button.text += "\n(not supported on Web)"
```

### 4.3 `CSharpTest.cs` — C# 支持

如果启用了 Mono 模块，此脚本提供额外的系统信息（通过 C# 预处理器定义）。

---

## 5. 关键概念详解

### 5.1 OS 类 vs DisplayServer 类

| 类 | 职责 |
|------|------|
| `OS` | 操作系统抽象，文件系统、环境变量、进程等 |
| `DisplayServer` | 显示相关，窗口管理、屏幕信息、剪贴板等 |

### 5.2 平台特性检测

使用 `OS.has_feature()` 检测当前平台特性：
- `"web"` — HTML5 平台
- `"double"` — 双精度构建
- `"windows"`、`"macos"`、`"linux"` 等

### 5.3 功能可用性检测

使用 `DisplayServer.has_feature()` 检测显示功能：
```gdscript
if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
    OS.alert("Clipboard I/O is not supported...")
```

---

## 6. 场景树全景

### 6.1 主场景 `os_test.tscn`

```
OsTest (Control)
├── HBoxContainer
│   ├── Features (RichTextLabel)       ← 左侧信息面板
│   └── GridContainer (按钮网格)       ← 右侧操作按钮
│       ├── OpenShellWeb (Button)
│       ├── OpenShellFolder (Button)
│       ├── ChangeWindowTitle (Button)
│       ├── ChangeWindowIcon (Button)
│       ├── MoveWindowToForeground (Button)
│       ├── RequestAttention (Button)
│       ├── VibrateDeviceShort (Button)
│       ├── VibrateDeviceLong (Button)
│       ├── AddGlobalMenuItems (Button)
│       ├── RemoveGlobalMenuItem (Button)
│       ├── GetClipboard (Button)
│       ├── SetClipboard (Button)
│       ├── DisplayAlert (Button)
│       └── KillCurrentProcess (Button)
└── CSharpTest (Node)                  ← C# 支持节点
```

---

## 7. 如何扩展

### 7.1 添加新的信息类别

在 `os_test.gd` 的 `_ready()` 中添加新的 `add_header()` 和 `add_line()` 调用：

```gdscript
add_header("Network")
add_line("Hostname", OS.get_environment("COMPUTERNAME"))
```

### 7.2 添加新的系统操作

在 `actions.gd` 中添加新的按钮处理方法，使用 `OS` 或 `DisplayServer` API。

---

## 推荐阅读路径

1. **`os_test.gd`** — 理解系统信息收集的核心逻辑
2. **`actions.gd`** — 看系统操作的实现
3. **`CSharpTest.cs`** — C# 集成（进阶）
