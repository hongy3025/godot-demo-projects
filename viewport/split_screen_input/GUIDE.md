# Split Screen Input - 源代码导读

> 本文档面向 Godot 新手，讲解如何实现多视口分屏输入路由，支持键盘和手柄的独立控制。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示如何实现本地多人分屏游戏的输入路由系统。核心特点：
- 多个 `SubViewport` 共享同一个 `World2D`
- 每个分屏可独立选择键盘按键集或手柄设备
- 输入事件根据配置路由到对应视口

---

## 2. 核心架构

```
root.gd → 初始化所有分屏
    ↓
SplitScreen (每个分屏)
    ├── OptionButton → 选择输入方式（WASD / IJKL / 方向键 / 小键盘 / 手柄）
    └── InputRoutingViewportContainer → 输入过滤器
        └── SubViewport
            └── Player (CharacterBody2D)
```

---

## 3. 文件逐层导读

### `root.gd` — 初始化管理器

```gdscript
const KEYBOARD_OPTIONS: Dictionary[String, Dictionary] = {
    "wasd":    {"keys": [KEY_W, KEY_A, KEY_S, KEY_D]},
    "ijkl":    {"keys": [KEY_I, KEY_J, KEY_K, KEY_L]},
    "arrows":  {"keys": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]},
    "numpad":  {"keys": [KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_8]},
}
```

为每个分屏分配位置、颜色、输入配置，并将所有分屏连接到同一个 `World2D`。

### `split_screen.gd` — 分屏配置

```gdscript
func set_config(config_dict: Dictionary):
    play.position = config_dict["position"]
    play.modulate = config_dict["color"]
    # 设置 OptionButton 选项
    for keyboard_opt in _keyboard_options:
        opt.add_item(keyboard_opt)
    for index in config_dict["joypads"]:
        opt.add_item("Joypad %s" % [index + 1])
    viewport.world_2d = config_dict["world"]  # 共享 World2D
```

### `sub_viewport_container.gd` — 输入路由 ⭐

```gdscript
class_name InputRoutingViewportContainer
extends SubViewportContainer

func _propagate_input_event(input_event: InputEvent) -> bool:
    if input_event is InputEventKey:
        return _current_keyboard_set.has(input_event.keycode)
    elif input_event is InputEventJoypadButton:
        return _current_joypad_device > -1 and input_event.device == _current_joypad_device
    return false
```

**关键：** 重写 `_propagate_input_event()` 方法，只有匹配当前配置的输入事件才会传递到子视口。

### `player.gd` — 玩家控制

```gdscript
func _unhandled_input(input_event: InputEvent) -> void:
    # 使用 ux_ 前缀的动作（自定义输入映射）
    if input_event.is_action_pressed(&"ux_up"):
        _movement.y -= 1
        get_viewport().set_input_as_handled()
```

---

## 4. 关键概念详解

### 输入路由机制

```
全局输入事件
    ↓
InputRoutingViewportContainer._propagate_input_event()
    ↓
如果是键盘事件 → 检查 keycode 是否在当前键盘集中
如果是手柄事件 → 检查 device ID 是否匹配
    ↓
匹配 → 事件传递到 SubViewport
不匹配 → 事件被拦截
```

### 共享 World2D

所有分屏使用同一个 `World2D`，意味着物理和渲染空间共享。玩家虽然在不同视口中，但处于同一个 2D 世界。

### 输入映射策略

使用 `ux_` 前缀的自定义动作（`ux_up`、`ux_down`、`ux_left`、`ux_right`），避免与 Godot 默认的 `ui_` 动作冲突。
