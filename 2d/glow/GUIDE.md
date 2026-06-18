# Glow for 2D - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何在 2D 游戏中使用 `WorldEnvironment` 节点实现辉光（Glow）效果。拖动洞穴图片左右移动，观察辉光在不同亮度区域的效果变化。

## 2. 快速上手

运行 `beach_cave.tscn`，鼠标拖拽洞穴图片左右移动，按 G 键切换辉光贴图（镜头污渍效果）。

## 3. 核心架构

```
beach_cave.tscn
├── WorldEnvironment       ← 辉光效果配置
├── Cave (Node2D)          ← 可拖动的洞穴图片
│   └── Sprite2D
└── CanvasLayer            ← UI 层（不受辉光影响）
    └── Label
```

## 4. 文件逐层导读

### `beach_cave.gd` — 主控脚本

```gdscript
const CAVE_LIMIT = 1000
```

**鼠标拖拽：**
```gdscript
if input_event is InputEventMouseMotion and input_event.button_mask > 0:
    cave.position.x = clampf(cave.position.x + input_event.screen_relative.x, -CAVE_LIMIT, 0)
```

**辉光贴图切换：**
```gdscript
if input_event.is_action_pressed(&"toggle_glow_map"):
    if $WorldEnvironment.environment.glow_map:
        $WorldEnvironment.environment.glow_map = null
        $WorldEnvironment.environment.glow_intensity = 0.8
    else:
        $WorldEnvironment.environment.glow_map = glow_map
        $WorldEnvironment.environment.glow_intensity = 1.6
```

## 5. 关键概念详解

### WorldEnvironment 辉光配置

项目设置中启用了 HDR 2D（`viewport/hdr_2d=true`），这是辉光在 2D 中工作的前提。

辉光参数：
- `glow_intensity`：辉光强度
- `glow_map`：辉光贴图（镜头污渍效果），叠加在辉光上产生纹理感

### CanvasLayer 隔离

Label 放在单独的 `CanvasLayer` 上，不受 `WorldEnvironment` 的辉光影响，保持清晰显示。

## 6. 场景树全景

```
BeachCave (Node2D)
├── WorldEnvironment
├── Cave (Node2D)
│   └── Sprite2D
└── CanvasLayer
    └── Label
```

## 7. 如何扩展

- 调整 `WorldEnvironment` 的 `glow_bloom` 参数改变辉光扩散范围
- 添加多个辉光贴图，用不同按键切换
- 在代码中动态调整 `glow_intensity` 实现呼吸灯效果
