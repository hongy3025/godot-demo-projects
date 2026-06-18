# Tween Demo - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示 Godot `Tween` 系统的进阶用法，包括属性插值、方法插值、并行/串行动画、链式调用、循环、弹性效果、路径动画等。

## 2. 快速上手

运行 `main.tscn`，勾选需要的动画步骤，点击"Start"播放动画。可调整速度、循环次数、缓动和过渡类型。

## 3. 核心架构

```
main.tscn
├── Main (Node)
│   ├── Icon (Sprite2D)       ← 动画对象
│   ├── Path2D                ← 路径（用于曲线动画）
│   ├── Progress (TextureProgressBar) ← 进度条
│   └── Control (UI)          ← 控制面板
```

## 4. 文件逐层导读

### `main.gd` — Tween 动画控制 ⭐

**创建 Tween：**
```gdscript
tween = create_tween().set_speed_scale(%SpeedSlider.value)
```

**串行动画：**
```gdscript
tween.tween_property(icon, ^"position", Vector2(400, 250), 1.0)
tween.tween_property(icon, ^"self_modulate", Color.RED, 1.0)
```

**并行动画：**
```gdscript
var tweener := tween.parallel().tween_property(icon, ^"rotation", TAU, 1.0)
```

**子 Tween（复杂并行）：**
```gdscript
tween.parallel().tween_callback(func():
    sub_tween = create_tween().set_trans(Tween.TRANS_SINE)
    sub_tween.tween_property(icon, ^"position:y", -150.0, 0.5).as_relative().set_ease(Tween.EASE_OUT)
    sub_tween.tween_property(icon, ^"position:y", 150.0, 0.5).as_relative().set_ease(Tween.EASE_IN)
)
```

**路径动画：**
```gdscript
tween.tween_method(
    func(v: float) -> void:
        icon.position = path.position + path.curve.sample_baked(v),
    0.0, path.curve.get_baked_length(), 3.0
)
```

**方法插值（倒计时）：**
```gdscript
tween.tween_method(do_countdown, 4, 1, 3)
```

**回调与延迟：**
```gdscript
tween.tween_callback(icon.hide).set_delay(0.1)
tween.tween_interval(2)
```

## 5. 关键概念详解

### Tween 核心方法

| 方法 | 用途 |
|------|------|
| `tween_property()` | 插值节点属性 |
| `tween_method()` | 插值调用方法 |
| `tween_callback()` | 在指定时间点调用 |
| `tween_interval()` | 插入等待时间 |
| `parallel()` | 与上一个动画并行 |
| `as_relative()` | 相对值（基于当前位置） |

### 缓动与过渡

- `set_trans()`：过渡类型（LINEAR/SINE/QUAD/CUBIC/ELASTIC/BOUNCE 等）
- `set_ease()`：缓动模式（IN/OUT/IN_OUT）

### Tween 生命周期

- `create_tween()`：创建并返回 Tween 实例
- `kill()`：立即停止并销毁
- `pause()`/`play()`：暂停/恢复
- `is_running()`：检查是否运行中

## 6. 场景树全景

```
Main (Node)
├── Icon (Sprite2D)
├── Path2D
│   └── Curve2D
├── Progress (TextureProgressBar)
├── CountdownLabel (Label)
└── Control
    ├── SpeedSlider
    ├── Loops
    ├── Infinite (CheckButton)
    ├── Reset (CheckButton)
    ├── Step toggles (CheckButton ×N)
    └── Trans/Ease dropdowns
```

## 7. 如何扩展

- 添加新的动画步骤，在 `start_animation()` 中添加新的 `tween_*` 调用
- 使用 `tween_property()` 动画任意节点的任意属性
- 组合多个 Tween 实例实现复杂动画序列
