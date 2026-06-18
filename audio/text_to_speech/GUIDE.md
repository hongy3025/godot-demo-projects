# Text-to-Speech Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑，帮助你理解"如何在 Godot 中使用文本转语音（TTS）功能"。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的文本转语音技术演示项目。核心思路是：

> **使用 `DisplayServer` 单例的 `tts_*()` 方法，调用操作系统 TTS API 实现文本朗读。**

项目演示了：
- 枚举系统可用语音
- 按语言过滤语音
- 朗读文本（普通/打断模式）
- 控制音量、音调、语速
- TTS 回调事件（开始/结束/取消/边界）

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，直接运行主场景 `control.tscn`。

选择语音 → 输入文本 → 点击 Speak 朗读。注意：需要操作系统支持 TTS。

---

## 3. 核心架构

```
┌─────────────────────────────────────────────┐
│              UI 层 (Control)                │
│  语音列表 / 文本输入 / 控制按钮 / 日志     │
├─────────────────────────────────────────────┤
│         DisplayServer TTS API 层            │
│  tts_get_voices() / tts_speak() / ...       │
├─────────────────────────────────────────────┤
│        操作系统 TTS 引擎                    │
│  Windows SAPI / macOS NSSpeech / ...        │
└─────────────────────────────────────────────┘
```

---

## 4. 文件逐层导读

### `voice_list.gd` — 主控制脚本 ⭐

**继承自 `Control`**，包含全部核心逻辑。

#### `_ready()` — 初始化语音列表

```gdscript
vs = DisplayServer.tts_get_voices()
for v in vs:
    var child: TreeItem = $Tree.create_item(root)
    child.set_text(0, v["name"])
    child.set_metadata(0, v["id"])
    child.set_text(1, v["language"])
```

1. 调用 `tts_get_voices()` 获取所有可用语音
2. 在 `Tree` 控件中显示语音名称和语言

#### 注册 TTS 回调

```gdscript
DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_STARTED, _on_utterance_start)
DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _on_utterance_end)
DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_CANCELED, _on_utterance_error)
DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_BOUNDARY, _on_utterance_boundary)
```

注册四种 TTS 回调事件。

#### `_on_button_speak_pressed()` — 朗读文本

```gdscript
DisplayServer.tts_speak(
    $Utterance.text,           # 要朗读的文本
    $Tree.get_selected().get_metadata(0),  # 语音 ID
    $HSliderVolume.value,      # 音量 (0-100)
    $HSliderPitch.value,       # 音调 (0.0-2.0)
    $HSliderRate.value,        # 语速 (0.0-2.0)
    id,                        # 话语 ID
    false                      # 是否打断
)
```

#### `_on_button_int_speak_pressed()` — 打断式朗读

```gdscript
DisplayServer.tts_speak(..., true)  # interrupt = true
```

与普通朗读的区别在于最后一个参数为 `true`，会打断当前正在朗读的文本。

#### `_on_utterance_boundary()` — 边界回调

```gdscript
func _on_utterance_boundary(pos: int, ut_id: int) -> void:
    $RichTextLabel.text = "[bgcolor=yellow][color=black]"
        + ut_map[ut_id].substr(0, pos)
        + "[/color][/bgcolor]"
        + ut_map[ut_id].substr(pos, -1)
```

在朗读到某个单词边界时高亮显示已读部分。

#### 多语言演示

```gdscript
# 英语
DisplayServer.tts_speak("Beware the Jabberwock, my son!", vc[0], ...)
# 西班牙语
DisplayServer.tts_speak("¡Cuidado, hijo, con el Fablistanón!", vc[0], ...)
# 俄语
DisplayServer.tts_speak("О, бойся Бармаглота, сын!", vc[0], ...)
```

---

## 5. 关键概念详解

### 5.1 `DisplayServer.tts_*()` API

| 方法 | 说明 |
|------|------|
| `tts_get_voices()` | 获取所有可用语音列表 |
| `tts_get_voices_for_language(lang)` | 按语言过滤语音 |
| `tts_speak(text, voice_id, volume, pitch, rate, ut_id, interrupt)` | 朗读文本 |
| `tts_stop()` | 停止朗读 |
| `tts_pause()` / `tts_resume()` | 暂停/恢复朗读 |
| `tts_is_paused()` / `tts_is_speaking()` | 查询状态 |
| `tts_set_utterance_callback(type, callable)` | 注册回调 |

### 5.2 回调事件类型

| 事件 | 触发时机 |
|------|----------|
| `TTS_UTTERANCE_STARTED` | 开始朗读 |
| `TTS_UTTERANCE_ENDED` | 朗读结束 |
| `TTS_UTTERANCE_CANCELED` | 朗读被取消/失败 |
| `TTS_UTTERANCE_BOUNDARY` | 到达单词边界 |

### 5.3 场景结构

```
Control
├── Tree                     ← 语音列表
├── Utterance (LineEdit)     ← 文本输入
├── ButtonSpeak (Button)     ← 朗读按钮
├── ButtonIntSpeak (Button)  ← 打断朗读按钮
├── ButtonStop (Button)      ← 停止按钮
├── ButtonPause (Button)     ← 暂停/恢复按钮
├── HSliderVolume            ← 音量滑块
├── HSliderPitch             ← 音调滑块
├── HSliderRate              ← 语速滑块
├── RichTextLabel            ← 高亮显示朗读进度
├── Log (TextEdit)           ← 事件日志
├── ColorRect                ← 朗读状态指示
└── LineEditFilterName       ← 名称过滤
```
