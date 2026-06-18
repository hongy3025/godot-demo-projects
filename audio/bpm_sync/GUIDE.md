# BPM Sync Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中同步音频播放与时间以实现一致的 BPM"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的 BPM（节拍每分钟）同步技术演示项目。核心思路是：

> **通过两种时钟源（系统时钟 vs 声音时钟）计算当前节拍位置，实现与音乐同步的节拍显示。**

项目包含两种同步模式：
| 模式 | 说明 |
|------|------|
| **系统时钟** | 使用 `Time.get_ticks_usec()` 计时，补偿音频延迟 |
| **声音时钟** | 使用 `AudioStreamPlayer.get_playback_position()` 获取播放位置 |

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `bpm_sync.tscn`。

操作方式：点击"Play with System Clock"或"Play with Sound Clock"按钮开始播放，界面实时显示当前节拍和时间。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│              UI 层 (Panel)                   │
│  按钮 / 节拍显示标签                         │
├─────────────────────────────────────────────┤
│            BPM 计算层                        │
│  beat = time * BPM / 60                     │
├─────────────────────────────────────────────┤
│          时钟源层                            │
│  系统时钟 (Time.get_ticks_usec)             │
│  声音时钟 (AudioStreamPlayer)               │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `bpm_sync.gd` — 主控制脚本 ⭐

**继承自 `Panel`**，包含全部核心逻辑。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `BPM` | 116 | 歌曲的节拍速度 |
| `BARS` | 4 | 每小节的拍数 |
| `COMPENSATE_FRAMES` | 2 | 补偿帧数 |
| `COMPENSATE_HZ` | 60.0 | 补偿频率 |

**枚举：**

```gdscript
enum SyncSource {
    SYSTEM_CLOCK,   // 系统时钟
    SOUND_CLOCK,    // 声音时钟
}
```

**核心方法：**

#### `_process(_delta)` — 每帧更新节拍

```gdscript
# 系统时钟方式：
time = (Time.get_ticks_usec() - time_begin) / 1000000.0
time -= time_delay

# 声音时钟方式：
time = $Player.get_playback_position()
        + AudioServer.get_time_since_last_mix()
        - AudioServer.get_output_latency()
        + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES

# 计算节拍：
var beat := int(time * BPM / 60.0)
```

#### `_on_PlaySystem_pressed()` — 系统时钟启动

```gdscript
time_begin = Time.get_ticks_usec()
time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
```

记录开始时间，并计算到下一次音频混合的延迟作为补偿。

#### `_on_PlaySound_pressed()` — 声音时钟启动

直接调用 `$Player.play()`，使用音频播放位置计算时间。

---

## 5. 关键概念详解

### 5.1 系统时钟 vs 声音时钟

| 特性 | 系统时钟 | 声音时钟 |
|------|----------|----------|
| 数据源 | `Time.get_ticks_usec()` | `AudioStreamPlayer.get_playback_position()` |
| 稳定性 | 高（无抖动） | 低（有抖动） |
| 准确性 | 需要补偿音频延迟 | 直接反映听到的声音 |
| 延迟补偿 | `AudioServer.get_time_to_next_mix() + get_output_latency()` | `get_time_since_last_mix() - get_output_latency()` |

### 5.2 延迟补偿公式

**系统时钟补偿：**
```
time_delay = 到下一次混合的时间 + 输出延迟
```

**声音时钟补偿：**
```
补偿值 = 自上次混合以来的时间 - 输出延迟 + (1/60) * 2
```

### 5.3 节拍计算公式

```
beat = time * BPM / 60
```

其中 `time` 是经过延迟补偿后的秒数。

### 5.4 场景结构

```
BPMSync (Panel)
├── Label           ← 显示 BEAT 和 TIME 信息
├── Player (AudioStreamPlayer)  ← 播放音乐文件
├── PlaySystem (Button)  ← 系统时钟播放按钮
└── PlaySound (Button)   ← 声音时钟播放按钮
```
