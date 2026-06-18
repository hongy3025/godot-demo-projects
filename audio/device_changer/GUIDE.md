# Audio Device Changer Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中动态切换音频输出设备"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的音频设备切换技术演示项目。核心思路是：

> **使用 `AudioServer` 单例的方法枚举系统音频输出设备，并在运行时动态切换。**

项目演示了三个核心功能：
- 枚举所有可用的音频输出设备
- 切换当前音频输出设备
- 显示当前设备信息和扬声器模式

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `Changer.tscn`。

操作方式：从列表中选择一个音频设备，点击"Change Device"按钮切换。点击"Play Audio"播放测试音乐。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│              UI 层 (Control)                │
│  设备列表 / 切换按钮 / 信息显示             │
├─────────────────────────────────────────────┤
│          AudioServer API 层                 │
│  get_output_device_list()                   │
│  get_output_device() / set_output_device()  │
│  get_speaker_mode()                         │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `Changer.gd` — 主控制脚本 ⭐

**继承自 `Control`**，包含全部核心逻辑。

**关键成员变量：**

```gdscript
@onready var item_list: ItemList = $ItemList
```

#### `_ready()` — 初始化设备列表

```gdscript
for item in AudioServer.get_output_device_list():
    item_list.add_item(item)

var device := AudioServer.get_output_device()
for i in item_list.get_item_count():
    if device == item_list.get_item_text(i):
        item_list.select(i)
        break
```

1. 遍历 `AudioServer.get_output_device_list()` 获取所有可用设备
2. 将设备名称添加到 `ItemList`
3. 自动选中当前正在使用的设备

#### `_process(_delta)` — 实时更新设备信息

```gdscript
$DeviceInfo.text = "Current Device: " + AudioServer.get_output_device() + "\n"
$DeviceInfo.text += "Speaker Mode: " + speaker_mode_text
```

每帧更新当前设备名称和扬声器模式（Stereo / Surround 3.1 / 5.1 / 7.1）。

#### `_on_Button_button_down()` — 切换设备

```gdscript
for item in item_list.get_selected_items():
    var device := item_list.get_item_text(item)
    AudioServer.set_output_device(device)
```

获取选中的设备名称，调用 `AudioServer.set_output_device()` 切换。

#### `_on_Play_Audio_button_down()` — 播放/停止测试音频

切换 `$AudioStreamPlayer` 的播放状态。

---

## 5. 关键概念详解

### 5.1 `AudioServer` 单例

Godot 的音频服务器单例，提供音频设备管理方法：

| 方法 | 说明 |
|------|------|
| `get_output_device_list()` | 返回所有可用音频输出设备的名称列表 |
| `get_output_device()` | 返回当前音频输出设备名称 |
| `set_output_device(name)` | 切换到指定音频输出设备 |
| `get_speaker_mode()` | 返回扬声器模式（立体声/环绕声） |

### 5.2 扬声器模式

```gdscript
AudioServer.SPEAKER_SURROUND_31  # 3.1 环绕声
AudioServer.SPEAKER_SURROUND_51  # 5.1 环绕声
AudioServer.SPEAKER_SURROUND_71  # 7.1 环绕声
```

### 5.3 场景结构

```
Changer (Control)
├── ItemList                    ← 设备列表
├── Button (Change Device)      ← 切换设备按钮
├── PlayAudio (Button)          ← 播放/停止测试音频
├── DeviceInfo (Label)          ← 当前设备信息
└── AudioStreamPlayer           ← 测试音频播放器
```
