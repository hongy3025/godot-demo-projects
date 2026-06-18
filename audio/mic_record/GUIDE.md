# Mic Record Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中从麦克风录制音频并播放/保存"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的麦克风录音技术演示项目。核心思路是：

> **使用 `AudioEffectCapture` 音频效果捕获麦克风输入，将录音保存为 `AudioStreamWAV` 并支持播放和导出 WAV 文件。**

项目演示了：
- 从麦克风录制音频
- 设置录音格式（8/16-bit、IMA ADPCM）、采样率和立体声
- 播放录音
- 保存为 WAV 文件

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `MicRecord.tscn`。

操作方式：点击"Record"开始录音，再次点击停止。然后可播放或保存录音。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│              UI 层 (Control)                │
│  录音按钮 / 播放按钮 / 保存按钮 / 设置      │
├─────────────────────────────────────────────┤
│         录音捕获层 (MicRecord.gd)           │
│  AudioEffectCapture → AudioStreamWAV        │
├─────────────────────────────────────────────┤
│       音频总线层 (Record 总线)              │
│  AudioEffectCapture 效果捕获输入             │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `MicRecord.gd` — 主控制脚本 ⭐

**继承自 `Control`**，包含全部核心逻辑。

**关键变量：**

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `effect` | — | `AudioEffectCapture` 实例 |
| `recording` | — | 录制的 `AudioStreamWAV` |
| `stereo` | true | 是否立体声 |
| `mix_rate` | 44100 | 采样率 |
| `format` | FORMAT_16_BITS | 音频格式 |

#### `_ready()` — 获取录音效果

```gdscript
var idx := AudioServer.get_bus_index(&"Record")
effect = AudioServer.get_bus_effect(idx, 0)
```

通过总线名称"Record"获取总线索引，再获取该总线上的第一个效果（`AudioEffectCapture`）。

#### `_on_record_button_pressed()` — 录音控制

```gdscript
if effect.is_recording_active():
    recording = effect.get_recording()
    recording.set_mix_rate(mix_rate)
    recording.set_format(format)
    recording.set_stereo(stereo)
    effect.set_recording_active(false)
else:
    effect.set_recording_active(true)
```

- 正在录音时：停止录音，获取 `AudioStreamWAV`，设置格式参数
- 未录音时：开始录音

#### `_on_play_button_pressed()` — 播放录音

```gdscript
$AudioStreamPlayer.stream = recording
$AudioStreamPlayer.play()
```

将录制的 `AudioStreamWAV` 设置为播放器的流并播放。

#### `_on_save_button_pressed()` — 保存 WAV

```gdscript
recording.save_to_wav(save_path)
```

直接调用 `AudioStreamWAV.save_to_wav()` 方法保存为 WAV 文件。

#### 格式设置方法

```gdscript
func _on_mix_rate_option_button_item_selected(index: int) -> void:
    match index:
        0: mix_rate = 11025
        1: mix_rate = 16000
        # ... 支持 11025 ~ 48000

func _on_format_option_button_item_selected(index: int) -> void:
    match index:
        0: format = AudioStreamWAV.FORMAT_8_BITS
        1: format = AudioStreamWAV.FORMAT_16_BITS
        2: format = AudioStreamWAV.FORMAT_IMA_ADPCM
```

---

## 5. 关键概念详解

### 5.1 `AudioEffectCapture`

这是一种特殊的音频总线效果，专门用于捕获经过该总线的音频数据。使用时需要在音频总线布局中手动添加。

### 5.2 录音流程

```
麦克风输入 → Record 总线 → AudioEffectCapture → get_recording() → AudioStreamWAV
```

### 5.3 音频格式对比

| 格式 | 位深 | 文件大小 | 质量 |
|------|------|----------|------|
| FORMAT_8_BITS | 8-bit | 小 | 低 |
| FORMAT_16_BITS | 16-bit | 中 | 高 |
| FORMAT_IMA_ADPCM | 4:1 压缩 | 很小 | 中 |

### 5.4 场景结构

```
MicRecord (Control)
├── RecordButton (Button)
├── PlayButton (Button)
├── SaveButton (Button)
│   └── Filename (LineEdit)
├── PlayMusic (Button)
├── MixRate (OptionButton)
├── Format (OptionButton)
├── Stereo (CheckButton)
├── Status (Label)
├── AudioStreamPlayer       ← 播放录音
└── AudioStreamPlayer2      ← 播放背景音乐
```
