# 3D 标签和文本 - 源代码导读

> 本文档面向 Godot 新手，剖析 3D 文本演示项目的架构与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)

---

## 1. 项目概述

项目名：**3D Labels and Texts**（`project.godot` 中 `config/name`）

展示 Godot 的两种 3D 文本技术：Label3D 和 TextMesh。

主场景：`3d_labels_and_texts.tscn`

## 2. 快速上手

左右箭头键切换不同的文本展示示例。鼠标拖拽旋转视角，滚轮缩放。

## 3. 核心架构

```
3d_labels_and_texts.tscn
├── Testers (Node3D)          ← 多个文本测试对象
├── CameraHolder (Node3D)
│   └── RotationX (Node3D)
│       └── Camera3D
└── UI (Control)
```

## 4. 文件逐层导读

### `3d_labels_and_texts.gd` — 主控脚本

与抗锯齿/CSG 演示相同的测试浏览模式。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_ready()` | 初始化摄像机 |
| `_unhandled_input()` | 鼠标旋转/缩放，切换测试对象 |
| `_process()` | 平滑移动摄像机 |
| `update_gui()` | 更新 UI，特殊处理 Label3DHealthBar 的输入框显隐 |

### `label_3d_layout.gd` — Label3D 布局脚本

控制 Label3D 节点的布局和文本更新。

### Label3D vs TextMesh

| 特性 | Label3D | TextMesh |
|------|---------|----------|
| 节点类型 | 独立节点 | PrimitiveMesh 资源 |
| 公告板 | 支持 | 不支持 |
| 深度 | 无（平面） | 可选（有厚度） |
| 彩色字体 | 支持 | 仅单色 |
| MSDF 字体 | 支持 | 支持 |
| 使用场景 | 通用文本 | 专业用途 |

### 项目设置

`project.godot` 中启用了 MSDF 字体和 Mipmap：
```ini
[gui]
theme/default_font_multichannel_signed_distance_field=true
theme/default_font_generate_mipmaps=true
```
