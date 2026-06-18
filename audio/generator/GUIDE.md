# Audio Generator Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中从 GDScript 生成并播放音频样本"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的音频生成技术演示项目。核心思路是：

> **使用 `AudioStreamGeneratorPlayback.push_frame()` 方法，在 GDScript 中逐帧生成正弦波音频数据并实时播放。**

项目演示了：
- 使用 `AudioStreamGenerator` 作为音频流类型
- 通过 `push_frame()` 逐帧推送音频数据
- 实时调整频率和音量

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `generator.tscn`。

操作方式：拖动频率滑块（20-2000 Hz）和音量滑块，实时听到生成的纯音正弦波。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│          UI 层 (Control)                    │
│  频率滑块 / 音量滑块 / 标签显示             │
├─────────────────────────────────────────────┤
│        音频生成层 (generator_demo.gd)       │
│  _fill_buffer() → push_frame()              │
├─────────────────────────────────────────────┤
│      AudioStreamGenerator 播放层            │
│  AudioStreamPlayer + GeneratorPlayback      │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `generator_demo.gd` — 主控制脚本 ⭐

**继承自 `Node`**，包含全部核心逻辑。

**关键变量：**

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `sample_hz` | 22050.0 | 采样率（每秒样本数） |
| `pulse_hz` | 440.0 | 频率（A4 音高） |
| `phase` | 0.0 | 波形相位（0~1） |
| `playback` | — | `AudioStreamGeneratorPlayback` 引用 |

#### `_ready()` — 初始化播放

```gdscript
$Player.stream.mix_rate = sample_hz
$Player.play()
playback = $Player.get_stream_playback()
_fill_buffer()
```

1. 设置 `AudioStreamGenerator` 的混合率
2. 开始播放
3. 获取 `AudioStreamGeneratorPlayback` 对象
4. 首次填充音频缓冲区

#### `_fill_buffer()` — 核心音频生成

```gdscript
var increment := pulse_hz / sample_hz
var to_fill: int = playback.get_frames_available()
while to_fill > 0:
    playback.push_frame(Vector2.ONE * sin(phase * TAU))
    phase = fmod(phase + increment, 1.0)
    to_fill -= 1
```

**逐行解析：**
1. `increment = 440 / 22050` — 每样本的相位增量
2. `get_frames_available()` — 查询播放器需要多少帧数据
3. `push_frame(Vector2.ONE * sin(phase * TAU))` — 生成立体声帧（左右声道相同）
4. `phase = fmod(phase + increment, 1.0)` — 相位累加并保持在 0~1 范围

#### `_process(_delta)` — 每帧填充缓冲区

```gdscript
_fill_buffer()
```

持续填充音频缓冲区，确保播放不中断。

#### 滑块回调

```gdscript
func _on_frequency_h_slider_value_changed(value: float) -> void:
    pulse_hz = value

func _on_volume_h_slider_value_changed(value: float) -> void:
    $Player.volume_db = linear_to_db(value)
```

频率直接修改 `pulse_hz`，音量使用 `linear_to_db()` 将线性值转换为分贝。

---

## 5. 关键概念详解

### 5.1 `AudioStreamGenerator` 与 `AudioStreamGeneratorPlayback`

- `AudioStreamGenerator` 是一种特殊的音频流，不播放预录文件，而是等待代码推送音频数据
- `AudioStreamGeneratorPlayback` 是它的播放控制器，通过 `push_frame()` 接收音频帧

### 5.2 正弦波生成公式

```
sample = sin(phase * 2π)
phase += frequency / sample_rate
```

- `phase` 在 0~1 之间循环
- `TAU = 2π`，是 Godot 内置常量

### 5.3 立体声帧

`push_frame()` 接受 `Vector2` 参数，其中 `x` 是左声道，`y` 是右声道。

### 5.4 场景结构

```
Generator (Control)
├── Player (AudioStreamPlayer)     ← 使用 AudioStreamGenerator 流
├── FrequencySlider (HSlider)      ← 频率调节（20-2000 Hz）
├── FrequencyLabel (Label)         ← 频率显示
├── VolumeSlider (HSlider)         ← 音量调节
└── VolumeLabel (Label)            ← 音量显示
```
