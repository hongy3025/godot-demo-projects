# 2D Lights as Mask - 源代码导读

> 本文档面向 Godot 新手，逐层剖析项目架构与代码逻辑。

---

## 1. 项目概述

展示如何使用 2D 灯光作为遮罩（Mask），用灯光照亮特定区域，其余部分保持黑暗，实现类似手电筒或探照灯的效果。

## 2. 快速上手

运行 `lightmask.tscn`，观察灯光如何作为遮罩只照亮部分区域。

## 3. 核心架构

```
lightmask.tscn
├── CanvasLayer (Background)  ← 背景层
├── CanvasLayer (Lights)      ← 灯光层
│   └── PointLight2D
└── CanvasLayer (Foreground)  ← 前景层
```

**注意：** 本项目没有 `.gd` 脚本文件，所有效果通过节点属性和 CanvasLayer 层级实现。

## 4. 关键概念详解

### 灯光作为遮罩的原理

1. 背景层包含场景图像
2. 灯光层包含 `PointLight2D`，设置为只照亮特定区域
3. 前景层覆盖在灯光上
4. 通过 `CanvasLayer` 的层级和 `Light2D` 的 `mode` 属性实现遮罩效果

### CanvasLayer 层级

`CanvasLayer` 的 `layer` 属性决定绘制顺序。灯光遮罩效果依赖于不同层之间的混合模式。

## 5. 场景树全景

```
LightMask (Node)
├── CanvasLayer (Background, layer 0)
│   └── Sprite2D
├── CanvasLayer (Lights, layer 1)
│   └── PointLight2D
│       └── LightOccluder2D
└── CanvasLayer (Foreground, layer 2)
    └── Sprite2D
```

## 6. 如何扩展

- 添加多个 `PointLight2D` 实现多光源遮罩
- 让灯光跟随鼠标移动
- 调整 `Light2D` 的 `energy` 和 `range` 属性改变光照范围
