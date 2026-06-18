# Pseudolocalization - 源代码导读

> 本文档面向 Godot 新手，剖析伪本地化功能的实现与配置。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Pseudolocalization**（Godot 4.6）

演示 Godot 的伪本地化功能——在不实际翻译的情况下模拟本地化效果，帮助发现 UI 布局问题。

---

## 2. 快速上手

运行 `Pseudolocalization.tscn`。切换各选项观察文本变化。

---

## 3. 核心架构

```
Pseudolocalization.tscn  ← 主场景
  └── Pseudolocalization.gd  ← 控制所有伪本地化选项
```

配置存储在 `project.godot` 的 `[internationalization]` 节。

---

## 4. 文件逐层导读

### `Pseudolocalization.gd` — 伪本地化控制 ⭐

**`_ready()` 初始化：** 从 ProjectSettings 读取当前配置并同步到 UI。

**选项切换回调：**

| 方法 | 设置项 | 说明 |
|------|--------|------|
| `_on_accents_toggled` | `replace_with_accents` | 用重音字符替换 |
| `_on_toggle_toggled` | `pseudolocalization_enabled` | 启用/禁用 |
| `_on_fake_bidi_toggled` | `fake_bidi` | 模拟双向文本 |
| `_on_double_vowels_toggled` | `double_vowels` | 双写元音 |
| `_on_override_toggled` | `override` | 覆盖已有翻译 |
| `_on_skip_placeholders_toggled` | `skip_placeholders` | 跳过占位符 |
| `_on_prefix_changed` | `prefix` | 添加前缀 |
| `_on_suffix_changed` | `suffix` | 添加后缀 |
| `_on_expansion_ratio_value_changed` | `expansion_ratio` | 文本扩展比例 |

**关键操作：** 每次修改后调用 `TranslationServer.reload_pseudolocalization()` 使更改生效。

**`_on_pseudolocalize_pressed()` 手动测试：**
```gdscript
$Main/Pseudolocalizer/Result.text = TranslationServer.pseudolocalize($Main/Pseudolocalizer/Key.text)
```

---

## 5. 关键概念详解

### 5.1 伪本地化选项

| 选项 | 效果 | 用途 |
|------|------|------|
| 重音替换 | `Hello` → `Héllö` | 测试字符渲染 |
| 双写元音 | `Hello` → `Heelloo` | 模拟文本膨胀 |
| 模拟 BiDi | `Hello` → `olleH` | 测试 RTL 布局 |
| 前缀/后缀 | `[!! Hello !!]` | 标记未翻译文本 |
| 扩展比例 | 按比例加长文本 | 测试布局弹性 |
| 跳过占位符 | 保留 `{name}` 不变 | 防止格式串损坏 |

### 5.2 项目配置

```ini
[internationalization]
pseudolocalization/use_pseudolocalization=true
pseudolocalization/double_vowels=true
```

### 5.3 关键 API

- `TranslationServer.pseudolocalization_enabled` — 全局开关
- `TranslationServer.reload_pseudolocalization()` — 重载配置
- `TranslationServer.pseudolocalize(text)` — 手动伪本地化
