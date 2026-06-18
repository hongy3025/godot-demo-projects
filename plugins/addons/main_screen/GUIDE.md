# Main Screen Plugin - 源代码导读

> 本文档面向 Godot 新手，讲解如何创建带主屏幕的编辑器插件。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

这是一个极简的 Godot 编辑器插件，演示如何创建一个带有 **主屏幕** 的插件。主屏幕是编辑器顶部（2D/3D/脚本按钮旁边）的自定义工作区。

---

## 2. 核心架构

```
main_screen_plugin.gd → EditorPlugin 入口
    ↓
main_panel.tscn → 主面板场景（UI 布局）
    ↓
print_hello.gd → 按钮点击逻辑
    ↓
handled_by_main_screen.gd → 标记节点类型
```

---

## 3. 文件逐层导读

### `main_screen_plugin.gd` — 插件入口

```gdscript
@tool
extends EditorPlugin

const MainPanel = preload("res://addons/main_screen/main_panel.tscn")

func _enter_tree() -> void:
    main_panel_instance = MainPanel.instantiate()
    get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
    _make_visible(false)

func _has_main_screen() -> bool:
    return true

func _make_visible(visible: bool) -> void:
    main_panel_instance.visible = visible

func _handles(object: Object) -> bool:
    return is_instance_of(object, preload("handled_by_main_screen.gd"))

func _get_plugin_name() -> String:
    return "Main Screen Plugin"
```

**关键方法：**

| 方法 | 说明 |
|------|------|
| `_has_main_screen()` | 返回 `true` 使插件显示在编辑器顶部 |
| `_make_visible(visible)` | 切换主面板显隐 |
| `_get_plugin_name()` | 返回按钮上显示的名称 |
| `_handles(object)` | 选中节点时判断是否由该插件处理 |

### `print_hello.gd` — 按钮逻辑

```gdscript
@tool
extends Button

func _on_PrintHello_pressed() -> void:
    print("Hello from the main screen plugin!")
```

### `handled_by_main_screen.gd` — 标记节点

```gdscript
extends Node
```

空脚本，仅用于类型标识。当选中附加此脚本的节点时，主屏幕插件会响应。

---

## 4. 关键概念详解

### 主屏幕插件的工作流程

```
点击编辑器顶部 "Main Screen Plugin" 按钮
    ↓
编辑器调用 _make_visible(true)
    ↓
main_panel_instance 显示
    ↓
点击面板中的按钮 → 打印消息
    ↓
切换到其他标签 → _make_visible(false)
```

### `get_editor_main_screen()`

返回编辑器主屏幕区域的根节点，所有主屏幕插件的 UI 都应添加到此节点下。
