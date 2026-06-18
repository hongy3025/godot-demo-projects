# BiDi and Font Features - 源代码导读

> 本文档面向 Godot 新手，剖析双向文本、OpenType 字体特性、可变字体和系统字体的实现。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**BiDi and Font Features**（Godot 4.6）

演示 Godot 的高级文本排版功能：
- **BiDi（双向文本）**：希伯来语等从右到左文字的显示
- **BiDi 覆盖**：自定义文本方向
- **OpenType 字体特性**：如连字、花体替代
- **可变字体**：动态调整字重、倾斜等轴
- **系统字体**：加载操作系统字体

---

## 2. 快速上手

运行 `bidi.tscn`。界面为 TabContainer 分页：
- Text direction — BiDi 演示
- Line break and fill — 换行和对齐
- Font features — OpenType 特性
- Variable fonts — 可变字体轴调节
- System fonts — 系统字体预览

---

## 3. 核心架构

```
bidi.tscn  ← 主场景（TabContainer 分页结构）
├── bidi.gd  ← 主逻辑脚本
└── custom_st_parser.gd  ← 自定义结构化文本解析器
```

---

## 4. 文件逐层导读

### `bidi.gd` — 主逻辑 ⭐

**`_ready()` 初始化：**
- Web 平台禁用系统字体功能
- 用 Tree 控件创建希伯来语层级菜单

**Tree 选中回调（`_on_Tree_item_selected`）：**
- 遍历父节点构建路径字符串
- 分别设置到带/不带结构化文本解析器的两个 LineEdit

**可变字体控制：**

| 方法 | 功能 |
|------|------|
| `_on_variable_size_value_changed` | 调整字号 |
| `_on_variable_weight_value_changed` | 调整字重轴 |
| `_on_variable_slant_value_changed` | 调整倾斜轴 |
| `_on_variable_cursive_toggled` | 切换手写体轴 |
| `_on_variable_casual_toggled` | 切换随意体轴 |
| `_on_variable_monospace_toggled` | 切换等宽轴 |

**关键技巧：** 修改 `variation_opentype` 时需要 `duplicate()` 字典再赋值，否则不生效。

**系统字体控制：**
- `_on_system_font_value_text_changed` 同步更新所有字体预览文本
- `_on_system_font_weight_value_changed` 设置字重
- `_on_system_font_italic_toggled` 切换斜体
- `_on_system_font_name_text_changed` 设置自定义字体名

### `custom_st_parser.gd` — 自定义结构化文本解析器

```gdscript
extends LineEdit

func _structured_text_parser(_args: Variant, p_text: String) -> Array:
    var tags := p_text.split(":")
    # 为每个标签段创建方向范围
    # 用 push_front 反转顺序
```

**作用：** 将 `"abc:def:ghi"` 格式的文本按 `:` 分割，为每段分配独立文本方向，演示 BiDi 覆盖。

---

## 5. 关键概念详解

### 5.1 BiDi（双向文本）

- 希伯来语和阿拉伯语从右到左书写
- Godot 的 TextServer 自动检测文本方向
- `TextServer.DIRECTION_AUTO` 让引擎自动判断

### 5.2 可变字体轴

| 轴标签 | 含义 | 范围 |
|--------|------|------|
| `weight` | 字重 | 100-900 |
| `slant` | 倾斜 | -15~15 |
| `custom_CRSV` | 手写体 | 0/1 |
| `custom_CASL` | 随意体 | 0/1 |
| `custom_MONO` | 等宽 | 0/1 |

### 5.3 系统字体

- 使用 `SystemFont` 资源类型
- 支持 `font_weight`、`font_italic`、`font_names` 属性
- Web 平台不支持系统字体枚举
