# Audio Effects - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用各种音频效果"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [如何扩展](#6-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的音频效果技术演示项目。核心思路是：

> **在音频总线上挂载 18 种音频效果，通过开关切换实时体验每种效果的声音变化。**

支持的音频效果包括：Amplify（放大）、BandLimit（带限）、BandPass（带通）、Chorus（合唱）、Compressor（压缩）、Delay（延迟）、Distortion（失真）、EQ 6/10/21（均衡器）、HighPass（高通）、LowShelf（低架）、Notch（陷波）、Panner（声像）、Phaser（移相）、PitchShift（变调）、Reverb（混响）、StereoEnhance（立体声增强）。

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `audio_effects.tscn`。

操作方式：点击左侧音效按钮播放音效/音乐，点击右侧开关切换音频效果。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│               UI 层 (Control)                │
│  音效按钮 / 音乐开关 / 效果开关              │
├─────────────────────────────────────────────┤
│            AudioServer 总线层                │
│  AudioServer.set_bus_effect_enabled()        │
├─────────────────────────────────────────────┤
│          音频效果层 (Bus 0 上 18 个效果)      │
│  Amplify / Chorus / Delay / Reverb / ...     │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `audio_effects.gd` — 主控制脚本 ⭐

**继承自 `Control`**，是整个项目的唯一脚本。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_on_toggle_music_toggled()` | 播放/停止背景音乐 |
| `_on_ding_button_pressed()` | 播放对应音效 |
| `_on_toggle_amplify_toggled()` | 切换 Amplify 效果开关 |

**核心 API：**

```gdscript
AudioServer.set_bus_effect_enabled(bus_index, effect_index, enabled)
```

- `bus_index = 0` 表示 Master 总线
- `effect_index` 从 0 到 17，对应 18 种音频效果在总线上的位置

**效果索引映射：**

| 索引 | 效果 | 索引 | 效果 |
|------|------|------|------|
| 0 | Amplify | 9 | EQ 21 |
| 1 | BandLimit | 10 | HighPass |
| 2 | BandPass | 11 | LowShelf |
| 3 | Chorus | 12 | Notch |
| 4 | Compressor | 13 | Panner |
| 5 | Delay | 14 | Phaser |
| 6 | Distortion | 15 | PitchShift |
| 7 | EQ 6 | 16 | Reverb |
| 8 | EQ 10 | 17 | StereoEnhance |

### `default_bus_layout.tres` — 总线布局文件

在 Godot 编辑器中通过"音频总线"面板创建，预先在 Master 总线上添加了 18 个音频效果插槽。

### `sfx/` — 音效资源目录

包含 7 个音效文件（Ding、Glass、Meow、Beeps、Trombone、Static、Whistle），均来自 Freesound，CC0 许可。

---

## 5. 关键概念详解

### 5.1 音频总线（Audio Bus）

Godot 的音频系统基于总线（Bus）架构。所有音频播放器将声音发送到总线，总线上的效果链依次处理音频数据。

### 5.2 `AudioServer.set_bus_effect_enabled()`

此方法动态启用/禁用总线上的某个效果。效果在总线布局中预先添加，但可以通过代码控制其激活状态。

### 5.3 场景结构

```
AudioEffects (Control)
├── MusicToggle (CheckButton)        ← 背景音乐开关
├── SoundEffects (VBoxContainer)     ← 音效按钮组
│   ├── Ding (Button)
│   ├── Glass (Button)
│   └── ... (7 个音效按钮)
└── EffectToggles (VBoxContainer)    ← 效果开关组
    ├── Amplify (CheckButton)
    ├── Chorus (CheckButton)
    └── ... (18 个效果开关)
```

---

## 6. 如何扩展

### 添加新的音效按钮

1. 在场景中添加新的 `Button` 节点
2. 在 `audio_effects.gd` 中添加对应的 `_on_xxx_pressed()` 方法

### 添加新的音频效果

1. 在 Godot 编辑器中打开音频总线面板
2. 在 Master 总线上添加新的效果
3. 在场景中添加对应的 `CheckButton`
4. 在脚本中添加对应的 `_on_toggle_xxx_toggled()` 方法
