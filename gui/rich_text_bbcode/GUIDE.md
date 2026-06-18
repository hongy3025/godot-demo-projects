# Rich Text Label with BBCode - 源代码导读

> 本文档面向 Godot 新手，剖析 RichTextLabel 和 BBCode 的使用方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Rich Text Label with BBCode**（Godot 4.6）

演示 RichTextLabel 的 BBCode 富文本支持，包括文本样式、图片嵌入、链接点击等。

---

## 2. 快速上手

运行 `rich_text_bbcode.tscn`。查看各种 BBCode 效果，点击链接。

---

## 3. 核心架构

```
rich_text_bbcode.tscn  ← 主场景（BBCode 内容在场景中直接编写）
  └── rich_text_bbcode.gd  ← 链接点击和暂停控制
```

---

## 4. 文件逐层导读

### `rich_text_bbcode.gd` — 交互逻辑

**链接点击处理：**
```gdscript
func _on_RichTextLabel_meta_clicked(meta: Variant) -> void:
    var err := OS.shell_open(str(meta))
    if err == OK:
        print("Opened link '%s' successfully!" % str(meta))
    else:
        print("Failed opening the link '%s'!" % str(meta))
```

**暂停切换：**
```gdscript
func _on_pause_toggled(button_pressed: bool) -> void:
    get_tree().paused = button_pressed
```

### BBCode 内容（在场景 RichTextLabel 中编写）

演示的 BBCode 标签包括：

| 标签 | 效果 |
|------|------|
| `[b]` `[/b]` | 粗体 |
| `[i]` `[/i]` | 斜体 |
| `[u]` `[/u]` | 下划线 |
| `[s]` `[/s]` | 删除线 |
| `[color=red]` | 文字颜色 |
| `[font_size=24]` | 字号 |
| `[url]` | 可点击链接 |
| `[img]` | 嵌入图片 |
| `[center]` | 居中对齐 |
| `[ol]` `[li]` | 有序列表 |
| `[ul]` `[li]` | 无序列表 |
| `[code]` | 代码样式 |
| `[table]` `[cell]` | 表格 |

---

## 5. 关键概念详解

### 5.1 BBCode 启用

RichTextLabel 的 `bbcode_enabled` 属性必须设为 `true`。

### 5.2 链接处理

- BBCode 中 `[url=链接]文本[/url]`
- `meta_clicked` 信号传递 URL 字符串
- 使用 `OS.shell_open()` 在系统浏览器中打开

### 5.3 暂停

- 按 Pause 键触发 `toggle_pause` 动作
- `get_tree().paused = true` 暂停整个场景树
- 再次点击恢复
