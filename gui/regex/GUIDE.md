# RegEx (Regular Expressions) - 源代码导读

> 本文档面向 Godot 新手，剖析正则表达式功能的使用方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**RegEx (Regular Expressions)**（Godot 4.6）

演示 Godot 正则表达式功能，也可作为正则表达式测试的练习场。

---

## 2. 快速上手

运行 `regex.tscn`。在输入框中输入正则表达式，下方实时显示匹配结果。

---

## 3. 核心架构

```
regex.tscn  ← 主场景
  └── regex.gd  ← 正则表达式匹配逻辑
```

---

## 4. 文件逐层导读

### `regex.gd` — 正则表达式引擎 ⭐

**核心变量：**
```gdscript
var regex := RegEx.new()
```

**`_ready()` 初始化：**
```gdscript
%Text.set_text("They asked me \"What's going on \\\"in the manor\\\"?\"")
update_expression(%Expression.text)
```
预设一段含转义引号的测试文本。

**`update_expression(text)` 编译正则：**
```gdscript
func update_expression(text: String) -> void:
    regex.compile(text)
    update_text()
```

**`update_text()` 显示匹配结果：**
1. 清空之前的匹配列表
2. 检查正则是否有效
3. 有效：`regex.search_all(%Text.get_text())` 获取所有匹配
4. 无效：显示红色错误提示

**匹配结果展示：**
```
RegEx match #1:
    Capture group #1: <匹配文本>
    Capture group #2: <捕获组文本>
```

**`_on_help_meta_clicked()`：**
```gdscript
OS.shell_open("https://regexr.com")  # 打开在线正则工具
```

---

## 5. 关键概念详解

### 5.1 RegEx 类核心方法

| 方法 | 用途 |
|------|------|
| `RegEx.new()` | 创建实例 |
| `compile(pattern)` | 编译正则模式 |
| `is_valid()` | 检查是否有效 |
| `search_all(text)` | 返回所有匹配的 `RegExMatch` 数组 |
| `search(text)` | 返回第一个匹配 |

### 5.2 RegExMatch 类

| 方法 | 用途 |
|------|------|
| `get_strings()` | 返回所有捕获组字符串数组 |
| `get_string(index)` | 返回指定捕获组 |
| `get_start(index)` | 返回匹配起始位置 |

### 5.3 错误处理

- 无效正则时输入框变红色
- 显示错误提示文本
- 使用 `modulate` 属性改变颜色
