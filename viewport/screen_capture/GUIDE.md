# Screen Capture - 源代码导读

> 本文档面向 Godot 新手，讲解如何截取屏幕截图并在 UI 中显示。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)

---

## 1. 项目概述

一个极简的屏幕截图演示项目。点击按钮即可截取当前视口画面，并在 UI 中显示缩略图。

---

## 2. 核心架构

```
点击 Capture 按钮
    ↓
get_viewport().get_texture().get_image()
    ↓
ImageTexture.create_from_image(img)
    ↓
TextureRect.set_texture(tex) → 显示截图
```

---

## 3. 文件逐层导读

### `screen_capture.gd` — 核心逻辑

```gdscript
extends Node

@onready var captured_image: TextureRect = $CapturedImage
@onready var capture_button: Button = $CaptureButton

func _on_capture_button_pressed() -> void:
    # 1. 获取视口纹理的 Image 数据
    var img := get_viewport().get_texture().get_image()

    # 2. 创建 ImageTexture
    var tex := ImageTexture.create_from_image(img)

    # 3. 设置到 TextureRect 显示
    captured_image.set_texture(tex)

    # 4. 按钮变色（区分每次截图）
    capture_button.modulate = Color.from_hsv(randf(), randf_range(0.2, 0.8), 1.0)
```

**关键 API：**

| 方法 | 说明 |
|------|------|
| `get_viewport().get_texture()` | 获取视口的 `ViewportTexture` |
| `ViewportTexture.get_image()` | 从纹理中提取 `Image` 数据 |
| `ImageTexture.create_from_image(img)` | 从 `Image` 创建可显示的纹理 |
