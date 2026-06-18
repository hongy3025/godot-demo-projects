# OpenXR Binding Modifiers Demo - 源代码导读

> 本文档面向 Godot 新手，讲解 OpenXR 绑定修饰器（Binding Modifiers）的使用方法。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 OpenXR 的两种绑定修饰器功能：**Analog Threshold Modifier**（模拟阈值修饰器）和 **DPad Modifier**（方向键修饰器）。在 VR 头显中查看控制器输入状态和修饰器效果。

---

## 2. 核心架构

```
start_vr.gd → 初始化 OpenXR
    ↓
openxr_action_map.tres → 配置动作和修饰器
    ↓
controller_state.gd → 显示控制器输入状态
    ↓
UI 面板显示 Trigger 值、阈值、DPad 状态
```

---

## 3. 文件逐层导读

### `start_vr.gd` — OpenXR 初始化

与大多数 XR 项目相同的标准初始化流程：
- 查找 OpenXR 接口
- 启用 XR 渲染
- 设置刷新率
- 连接会话事件

### `controller_state.gd` — 控制器状态显示 ⭐

```gdscript
func _process(_delta: float) -> void:
    if controller:
        var trigger_input = controller.get_float(&"trigger")
        var trigger_click = controller.is_button_pressed(&"trigger_click")

        # 记录阈值变化
        if trigger_click:
            off_trigger_threshold = min(off_trigger_threshold, trigger_input)
        else:
            on_trigger_threshold = max(on_trigger_threshold, trigger_input)

        # DPad 状态
        dpad_up_node.button_pressed = controller.is_button_pressed(&"up")
        dpad_down_node.button_pressed = controller.is_button_pressed(&"down")
```

**UI 显示内容：**
- Trigger 输入值（滑块）
- Trigger Click 状态（复选框）
- On/Off 阈值
- DPad 四方向状态

---

## 4. 关键概念详解

### Analog Threshold Modifier

修改模拟输入（如扳机键）触发布尔值的阈值：

```
默认: 按下时 trigger > 0.5 → trigger_click = true
修饰器: 可自定义 on_threshold 和 off_threshold
```

### DPad Modifier

将摇杆/触摸板输入映射为四方向 DPad 输入：

```
摇杆向左推 → left = true
摇杆向右推 → right = true
摇杆向上推 → up = true
摇杆向下推 → down = true
```
