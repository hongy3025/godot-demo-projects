# Translation Demo - 源代码导读

> 本文档面向 Godot 新手，剖析游戏国际化的实现方式，包括 CSV 和 PO 两种翻译格式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Translation Demo**（Godot 4.6）

演示 Godot 国际化功能：
- **CSV 翻译**：键值对格式
- **PO/gettext 翻译**：支持复数形式的翻译格式
- **资源重映射**：根据语言自动切换图片和音频

---

## 2. 快速上手

运行 `translation_demo_csv.tscn`。点击语言按钮切换界面语言。

---

## 3. 核心架构

```
translation_demo_csv.tscn  ← CSV 翻译场景
└── translation_csv.gd
translation_demo_po.tscn   ← PO 翻译场景
└── translation_po.gd
translations/
├── csv/   ← CSV 翻译文件
└── po/    ← PO 翻译文件
```

---

## 4. 文件逐层导读

### `translation_csv.gd` — CSV 翻译

**语言切换：**
```gdscript
func _on_english_pressed() -> void:
    TranslationServer.set_locale("en")
    _print_intro()
```

**获取翻译：**
```gdscript
print(tr(&"KEY_INTRO"))  # 使用键名获取翻译
```

**`_print_intro()` 输出：**
```gdscript
print_rich("\n[b]Language:[/b] %s (%s)" % [TranslationServer.get_locale_name(...), TranslationServer.get_locale()])
```

### `translation_po.gd` — PO 翻译

**PO 翻译使用源文本作为键：**
```gdscript
print(tr(&"Hello, this is a translation demo project."))
```

**复数翻译：**
```gdscript
var days_passed := randi_range(1, 3)
print(tr_n(&"One day ago.", &"{days} days ago.", days_passed).format({ days = days_passed }))
```
- `tr_n()` 根据数量选择单数/复数形式
- `.format()` 插入变量

### 资源重映射

`project.godot` 中配置：
```ini
locale/translation_remaps={
"res://audio/hello_en.wav": PackedStringArray("res://audio/hello_es.wav:es", ...)
"res://images/flag_uk.webp": PackedStringArray("res://images/flag_japan.webp:ja", ...)
}
```

切换语言时，Godot 自动替换对应资源。

---

## 5. 关键概念详解

### 5.1 CSV vs PO

| 特性 | CSV | PO |
|------|-----|-----|
| 键方式 | 自定义键名 | 源文本作为键 |
| 复数支持 | 不支持 | 支持 `tr_n()` |
| 工具 | 电子表格软件 | Poedit 等专用工具 |

### 5.2 TranslationServer API

| 方法 | 用途 |
|------|------|
| `set_locale(locale)` | 切换语言 |
| `get_locale()` | 获取当前语言代码 |
| `get_locale_name(code)` | 获取语言显示名称 |
| `tr(key)` | 获取翻译 |
| `tr_n(msgid, msgid_plural, n)` | 获取复数翻译 |

### 5.3 资源重映射

- 图片、音频等资源可根据语言自动切换
- 在 ProjectSettings 中配置 `locale/translation_remaps`
- 无需代码干预，Godot 自动处理
