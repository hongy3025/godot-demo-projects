# OpenXR Composition Layers - 源代码导读

> 本文档面向 Godot 新手，讲解如何使用 OpenXR 合成层（Composition Layers）在 VR 中呈现高清 2D UI。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

演示 OpenXR 合成层功能。在 VR 头显中，2D UI 经过镜头畸变后质量下降。合成层将 2D 内容在镜头畸变之后叠加，保持清晰度。本 demo 使用 Equirect（弧形屏幕）形状展示合成层效果。

---

## 2. 核心架构

```
main.gd → 管理控制器指针和交互
    ↓
handle_pointers.gd → 将控制器射线转换为鼠标事件
    ↓
OpenXRCompositionLayerEquirect → 合成层节点
    ↓
SubViewport → 渲染 2D UI
    ↓
ui.gd → 按钮和光标逻辑
```

---

## 3. 文件逐层导读

### `main.gd` — 控制器管理

```gdscript
func _on_left_hand_button_pressed(action_name):
    if action_name == "select":
        # 切换到左手
        $XROrigin3D/LeftHand/Pointer.visible = true
        $XROrigin3D/RightHand/Pointer.visible = false
        active_hand = $XROrigin3D/LeftHand
        $XROrigin3D/OpenXRCompositionLayerEquirect.controller = active_hand
        # 触觉反馈脉冲
        active_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)
```

### `handle_pointers.gd` — 射线交互 ⭐

继承 `OpenXRCompositionLayerEquirect`，将控制器射线与合成层的交点转换为鼠标事件：

```gdscript
func _process(_delta):
    var controller_t := controller.global_transform
    var intersect := intersects_ray(controller_t.origin, -controller_t.basis.z)

    if intersect != NO_INTERSECTION:
        # 移动事件
        var event := InputEventMouseMotion.new()
        event.relative = to - from
        event.position = to
        layer_viewport.push_input(event)

        # 点击事件
        if not is_pressed and was_pressed:
            var event := InputEventMouseButton.new()
            event.button_index = MOUSE_BUTTON_LEFT
            event.pressed = false
            layer_viewport.push_input(event)
```

### `ui.gd` — 2D UI 逻辑

```gdscript
func _input(event):
    if event is InputEventMouseMotion:
        $Cursor.position = mouse_motion.position - Vector2(16, 16)

func _on_button_pressed():
    button_count += 1
    $CountLabel.text = "The button has been pressed %d times!" % [button_count]
```

---

## 4. 关键概念详解

### 合成层的工作原理

```
正常渲染:
3D 场景 → 镜头畸变 → 显示（UI 也经过畸变，质量下降）

合成层:
3D 场景 → 镜头畸变 → 叠加合成层（UI 在畸变后叠加，保持清晰）
```

### 合成层形状

| 形状 | 说明 |
|------|------|
| `OpenXRCompositionLayerQuad` | 平面矩形 |
| `OpenXRCompositionLayerEquirect` | 弧形屏幕（本 demo 使用） |
| `OpenXRCompositionLayerCylinder` | 圆柱面 |

### 回退机制

如果 XR 运行时不支持合成层，Godot 自动回退到在 3D 场景中渲染 UI。
