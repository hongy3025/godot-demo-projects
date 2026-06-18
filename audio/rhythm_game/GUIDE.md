# Rhythm Game - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中构建精确同步的节奏游戏"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的节奏游戏技术演示项目。核心思路是：

> **使用 1€ 滤波器融合音频时钟和系统时钟，获得既稳定又精确的节拍追踪，实现音符与音乐的精确同步。**

关键技术点：
- 双时钟融合（音频时钟 + 系统时钟）
- 1€ 滤波器消除播放位置抖动
- 可调节的输入延迟补偿

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景。

操作方式：按空格键击打音符，根据时机判定 Perfect/Good/Miss。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│          场景层 (scenes/main/)              │
│  UI 显示 / 游戏流程控制                     │
├─────────────────────────────────────────────┤
│        游戏状态层 (game_state/)             │
│  Conductor / NoteManager / Metronome        │
├─────────────────────────────────────────────┤
│         全局工具层 (globals/)               │
│  GlobalSettings / OneEuroFilter / ChartData │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `globals/global_settings.gd` — 全局设置

作为 Autoload 单例，管理游戏全局参数：

| 属性 | 默认值 | 说明 |
|------|--------|------|
| `use_filtered_playback` | true | 是否使用滤波播放 |
| `enable_metronome` | false | 是否开启节拍器 |
| `input_latency_ms` | 20 | 输入延迟补偿（毫秒） |
| `scroll_speed` | 400 | 音符滚动速度 |
| `selected_chart` | THE_COMEBACK | 当前选中的谱面 |

### `globals/one_euro_filter.gd` — 1€ 滤波器 ⭐

**核心算法：** 自适应低通滤波器，根据变化速率动态调整截止频率。

```gdscript
func filter(value: float, delta: float) -> float:
    var rate: float = 1.0 / delta
    var dx: float = (value - x_filter.last_value) * rate
    var edx: float = dx_filter.filter(dx, alpha(rate, d_cutoff))
    var cutoff: float = min_cutoff + beta * abs(edx)
    return x_filter.filter(value, alpha(rate, cutoff))
```

- 变化快时：截止频率升高，减少延迟
- 变化慢时：截止频率降低，更多平滑

### `game_state/conductor.gd` — 节拍追踪器 ⭐

**核心职责：** 融合音频时钟和系统时钟，提供稳定的节拍信息。

#### 双时钟策略

```gdscript
# 音频时钟（精确但抖动）
_song_time_audio = player.get_playback_position()
    - first_beat_offset_ms / 1000.0
    + last_mix
    - _cached_output_latency

# 系统时钟（稳定但可能漂移）
_song_time_system = (Time.get_ticks_usec() / 1000000.0) - _song_time_begin
```

#### 1€ 滤波器融合

```gdscript
func _physics_process(delta: float) -> void:
    var audio_system_delta := _song_time_audio - _song_time_system
    _filtered_audio_system_delta = _filter.filter(audio_system_delta, delta)
```

在 `_physics_process` 中运行滤波，确保稳定的更新率。

#### 节拍计算

```gdscript
func get_current_beat() -> float:
    var song_time := _song_time_system + _filtered_audio_system_delta
    return song_time / get_beat_duration()
```

### `game_state/note_manager.gd` — 音符管理器 ⭐

**核心职责：** 生成音符、判定击打结果。

#### 音符生成

```gdscript
var chart_data := ChartData.get_chart_data(chart)
for measure_i in range(chart_data.size()):
    var measure: Array = chart_data[measure_i]
    var subdivision := 1.0 / measure.size() * 4
    for note_i: int in range(measure.size()):
        var beat := measure_i * 4 + note_i * subdivision
        if measure[note_i] == 1:
            note_beats.append(beat)
```

将谱面数据（小节/拍子格式）转换为绝对节拍位置。

#### 击打判定

```gdscript
const HIT_MARGIN_PERFECT = 0.050  # ±50ms
const HIT_MARGIN_GOOD = 0.150     # ±150ms
const HIT_MARGIN_MISS = 0.300     # ±300ms
```

根据击打时间误差分为 Perfect / Good / Miss 三个等级。

### `game_state/metronome.gd` — 节拍器

```gdscript
var curr_beat := conductor.get_current_beat() + _cached_latency
if GlobalSettings.enable_metronome and floor(curr_beat) > floor(_last_beat):
    play()
```

每拍播放一次节拍器声音。

---

## 5. 关键概念详解

### 5.1 双时钟融合策略

| 时钟 | 优点 | 缺点 |
|------|------|------|
| 音频时钟 | 与听到的声音精确同步 | 每帧抖动大 |
| 系统时钟 | 稳定无抖动 | 可能漂移（暂停/卡顿） |

**融合方案：** 系统时钟 + 1€ 滤波后的差值

### 5.2 1€ 滤波器参数

| 参数 | 作用 | 值 |
|------|------|-----|
| `min_cutoff` | 最小截止频率（静止时平滑度） | 0.1 |
| `beta` | 速度敏感度（快速响应） | 5.0 |

### 5.3 文件结构

```
rhythm_game/
├── globals/
│   ├── global_settings.gd      ← Autoload 全局设置
│   ├── one_euro_filter.gd      ← 1€ 滤波器实现
│   ├── chart_data.gd           ← 谱面数据
│   └── enums.gd                ← 枚举定义
├── game_state/
│   ├── conductor.gd            ← 节拍追踪器 ⭐
│   ├── note_manager.gd         ← 音符管理器 ⭐
│   ├── metronome.gd            ← 节拍器
│   └── play_stats.gd           ← 游戏统计
├── objects/
│   ├── note/                   ← 音符场景
│   └── guide/                  ← 引导线场景
└── scenes/
    └── main/                   ← 主场景
```
