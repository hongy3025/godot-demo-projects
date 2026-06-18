# Input Mapping GUI - 源代码导读

> 本文档面向 Godot 新手，剖析输入按键重映射界面的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Input Mapping GUI**（Godot 4.6）

演示如何构建输入按键重映射界面：
- 点击按钮更改绑定的按键
- 将按键设置持久化到磁盘

---

## 2. 快速上手

运行 `InputRemapMenu.tscn`。点击按钮，按下新按键完成重映射。

---

## 3. 核心架构

```
InputRemapMenu.tscn  ← 主场景
├── ActionRemapButton.tscn  ← 可复用的重映射按钮
│   └── ActionRemapButton.gd
└── KeyPersistence.gd  ← 自动加载单例，持久化按键设置
```

---

## 4. 文件逐层导读

### `ActionRemapButton.gd` — 重映射按钮 ⭐

**核心逻辑：**

```gdscript
@export var action: String = "ui_up"  # 导出的动作名
```

**`_ready()`：**
- 验证动作存在：`InputMap.has_action(action)`
- 初始不处理键盘输入：`set_process_unhandled_key_input(false)`
- 显示当前按键：`display_current_key()`

**`_toggled(is_button_pressed)` 切换状态：**

| 状态 | 按钮文本 | 颜色 | 键盘处理 |
|------|----------|------|----------|
| 未按下 | 当前按键名 | 白色 | 关闭 |
| 按下 | `<press a key>` | 黄色 | 开启 |

**`_unhandled_key_input(input_event)` 按键捕获：**
```gdscript
func _unhandled_key_input(input_event: InputEvent) -> void:
    if input_event is InputEventKey and input_event.keycode != KEY_ENTER:
        remap_action_to(input_event)
        button_pressed = false
```
- 跳过 Enter 键（用于键盘导航）
- 调用 `remap_action_to()` 完成重映射

**`remap_action_to(input_event)` 重映射：**
```gdscript
InputMap.action_erase_events(action)     # 清除旧绑定
InputMap.action_add_event(action, input_event)  # 添加新绑定
KeyPersistence.keymaps[action] = input_event    # 保存到字典
KeyPersistence.save_keymap()                    # 写入磁盘
```

### `KeyPersistence.gd` — 自动加载单例 ⭐

**`_ready()` 初始化：**
- 遍历所有 InputMap 动作，构建初始 keymaps 字典
- 调用 `load_keymap()` 加载已保存的配置

**`load_keymap()` 加载：**
- 检查 `user://keymaps.dat` 是否存在
- 逐动作校验，确保新增/删除的动作正确处理
- 同时更新 InputMap 和内存字典

**`save_keymap()` 保存：**
```gdscript
var file := FileAccess.open(keymaps_path, FileAccess.WRITE)
file.store_var(keymaps, true)  # 存储整个字典
file.close()
```

---

## 5. 关键概念详解

### 5.1 自动加载（Autoload）

`project.godot` 中配置：
```
[autoload]
KeyPersistence="*res://KeyPersistence.gd"
```
`*` 表示自动创建实例，全局可通过 `KeyPersistence` 访问。

### 5.2 数据持久化

- 存储路径：`user://keymaps.dat`（平台独立的用户数据目录）
- 格式：Godot 的 `store_var` / `get_var`（Variant 序列化）
- 加载时校验：防止旧版本保存文件包含无效动作

### 5.3 输入事件处理

- 使用 `_unhandled_key_input` 而非 `_input`，避免与 GUI 控件事件冲突
- 支持扩展为手柄输入（注释中提示）
