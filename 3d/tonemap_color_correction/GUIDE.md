# 色调映射和颜色校正 - 源代码导读

> 本文档面向 Godot 新手，剖析色调映射和颜色校正演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**Tonemapping and Color Correction**（`project.godot` 中 `config/name`）

展示各种色调映射算子及其与多种颜色校正纹理（1D 和 3D）的交互。包含生成中性 3D LUT 纹理的脚本。

主场景：`test.tscn`

## 2. 快速上手

通过 UI 面板切换不同的色调映射算子和颜色校正 LUT，实时观察场景变化。

## 3. 核心架构

```
test.tscn
├── WorldEnvironment
├── DirectionalLight3D
├── Camera3D
├── 3D 场景物体
└── UI (Control)              ← 参数控制面板
```

## 4. 文件逐层导读

### `test_scene.gd` — 场景主控

管理色调映射和颜色校正的切换。

### `options.gd` — 参数控制

**色调映射算子：**

| 算子 | 说明 |
|------|------|
| Linear | 线性映射（无色调映射） |
| Reinhard | Reinhard 色调映射 |
| Filmic | 电影级色调映射 |
| ACES | Academy Color Encoding System |
| Custom | 自定义映射 |

### `neutral_luts/3d/create_neutral_3d_luts.gd` — 3D LUT 生成

生成中性 3D LUT 纹理的脚本，可作为颜色校正的起点。

### `gradients/gradient_bars.gd` — 渐变条

显示颜色渐变条，用于观察色调映射对颜色的影响。

### `gradients/gradients_controls.gd` — 渐变控制

控制渐变条的显示参数。

### 颜色校正

| 校正方式 | 说明 |
|---------|------|
| 1D LUT | 一维查找表，调整亮度/对比度 |
| 3D LUT | 三维查找表，精确颜色映射 |
| 屏幕调整 | 亮度/对比度/饱和度 |
