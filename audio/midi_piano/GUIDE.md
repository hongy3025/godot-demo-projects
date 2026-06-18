# MIDI Piano Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中处理 MIDI 输入并构建可交互的钢琴"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的 MIDI 钢琴技术演示项目。核心思路是：

> **使用 `InputEventMIDI` 接收 MIDI 设备输入，动态生成 88 键钢琴键盘，通过改变 `AudioStreamPlayer.pitch_scale` 实现不同音高。**

项目支持三种触发方式：
- MIDI 设备输入（如 Yamaha MX88）
- 鼠标点击琴键
- 代码调用 `activate()` / `deactivate()` 方法

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `piano.tscn`。

连接 MIDI 设备后按琴键即可发声，或直接用鼠标点击钢琴键盘。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│          MIDI 输入层 (piano.gd)             │
│  InputEventMIDI → 按键映射                  │
├─────────────────────────────────────────────┤
│         钢琴键盘生成层 (piano.gd)           │
│  88 键动态生成 / 黑白键布局                 │
├─────────────────────────────────────────────┤
│         琴键逻辑层 (piano_key.gd)           │
│  activate() / deactivate() / 音高计算       │
├─────────────────────────────────────────────┤
│         音频播放层                          │
│  AudioStreamPlayer + pitch_scale 变调       │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `piano.gd` — 主控制脚本 ⭐

**继承自 `Control`**，负责键盘生成和 MIDI 输入处理。

**常量：**

| 常量 | 值 | 说明 |
|------|-----|------|
| `START_KEY` | 21 | 最低音 MIDI 编号（A0） |
| `END_KEY` | 108 | 最高音 MIDI 编号（C8） |

#### `_ready()` — 生成钢琴键盘

```gdscript
for i in range(START_KEY, END_KEY + 1):
    piano_key_dict[i] = _create_piano_key(i)

OS.open_midi_inputs()
```

1. 循环生成 88 个琴键
2. 调用 `OS.open_midi_inputs()` 打开 MIDI 输入

#### `_input(input_event)` — MIDI 事件处理

```gdscript
if input_event is not InputEventMIDI:
    return
var midi_event: InputEventMIDI = input_event
var key: PianoKey = piano_key_dict[midi_event.pitch]
if midi_event.message == MIDI_MESSAGE_NOTE_ON:
    key.activate()
else:
    key.deactivate()
```

根据 MIDI 消息类型（Note On/Off）调用琴键的激活/停用方法。

#### `_create_piano_key(pitch_index)` — 琴键创建

```gdscript
if _is_note_index_sharp(note_index):
    piano_key = BlackKeyScene.instantiate()
    black_keys.add_child(piano_key)
else:
    piano_key = WhiteKeyScene.instantiate()
    white_keys.add_child(piano_key)
```

根据音级索引判断是黑键还是白键，实例化对应场景。

#### 音级判断

```gdscript
func _is_note_index_sharp(note_index: int) -> bool:
    return note_index in [1, 4, 6, 9, 11]  # A#, C#, D#, F#, G#

func _is_note_index_lacking_sharp(note_index: int) -> bool:
    return note_index in [2, 7]  # B, E（没有升号）
```

### `piano_key.gd` — 琴键逻辑

**继承自 `Control`**，每个琴键独立控制音高和颜色。

```gdscript
func setup(pitch_index: int) -> void:
    var exponent := (pitch_index - 69.0) / 12.0
    pitch_scale = pow(2, exponent)

func activate() -> void:
    key.color = (Color.YELLOW + start_color) / 2
    var audio := AudioStreamPlayer.new()
    audio.stream = preload("res://piano_keys/A440.wav")
    audio.pitch_scale = pitch_scale
    audio.play()
```

**音高计算公式：** `pitch_scale = 2^((pitch - 69) / 12)`，其中 69 是 A440 的 MIDI 编号。

### `piano_key_color.gd` — 鼠标点击处理

```gdscript
func _gui_input(input_event: InputEvent) -> void:
    if input_event is InputEventMouseButton and input_event.pressed:
        parent.activate()
```

---

## 5. 关键概念详解

### 5.1 MIDI 音高编号

MIDI 标准中，音高用 0-127 的整数表示：
- 69 = A4（440 Hz）
- 每 +12 = 高一个八度
- 每 -12 = 低一个八度

### 5.2 变调原理

使用单个 A440 采样，通过 `pitch_scale` 属性变调：
```
pitch_scale = 2^((target_pitch - 69) / 12)
```

### 5.3 场景结构

```
Piano (Control)
├── WhiteKeys (HBoxContainer)    ← 白键容器
│   ├── PianoKey21 (PianoKey)    ← C 键
│   ├── PianoKey22 (PianoKey)    ← D 键
│   └── ...
├── BlackKeys (HBoxContainer)    ← 黑键容器
│   ├── PianoKey22 (PianoKey)    ← C# 键
│   └── ...
└── Placeholder (Control)        ← 对齐占位
```
