# Run-time File Saving and Loading - 源代码导读

> 本文档面向 Godot 新手，剖析运行时加载和保存各种文件类型的实现方式。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)

---

## 1. 项目概述

项目名称：**Run-time File Saving and Loading**（Godot 4.6）

演示在不经过 Godot 资源导入系统的情况下，运行时加载/保存各种文件类型：
- 图像（JPG/PNG/WebP/SVG/TGA/BMP）
- 音频（Ogg/MP3/WAV）
- 3D 场景（glTF/FBX）
- 字体（TTF/OTF/WOFF/WOFF2）
- ZIP 存档

---

## 2. 快速上手

运行 `runtime_save_load.tscn`。浏览选择文件，查看预览，可导出修改后的文件。

---

## 3. 核心架构

```
runtime_save_load.tscn  ← 主场景
└── runtime_save_load.gd  ← 文件加载/保存/导出逻辑
examples/  ← 示例文件（3D 模型、音频等）
```

---

## 4. 文件逐层导读

### `runtime_save_load.gd` — 文件操作引擎 ⭐

**`open_file(path)` 文件分发：**

| 文件类型 | 加载方式 | 显示方式 |
|----------|----------|----------|
| 图像 | `Image.load_from_file(path)` | `TextureRect` |
| 音频 | `AudioStream*.load_from_file(path)` | 播放按钮 |
| glTF/glb | `GLTFDocument.append_from_file()` | `SubViewport` 3D 预览 |
| FBX | `FBXDocument.append_from_file()` | `SubViewport` 3D 预览 |
| 字体 | `FontFile.load_dynamic_font()` | `Label` 预览 |
| ZIP | `ZIPReader.open()` | `ItemList` 文件列表 |
| 其他 | `FileAccess.get_file_as_string()` | 文本显示 |

**图像加载示例：**
```gdscript
var image := Image.load_from_file(path)
texture_viewer.texture = ImageTexture.create_from_image(image)
```

**3D 场景加载：**
```gdscript
var gltf_document := GLTFDocument.new()
var gltf_state := GLTFState.new()
var error := gltf_document.append_from_file(path, gltf_state)
if error == OK:
    scene_viewer_root_node = gltf_document.generate_scene(gltf_state)
    scene_viewer.add_child(scene_viewer_root_node)
```

**导出功能（`_on_export_file_dialog_file_selected`）：**

| 类型 | 导出方式 |
|------|----------|
| 文本 | `FileAccess.store_string()` |
| 图像 | `Image.save_png()` / `save_jpg()` / `save_webp()` |
| 3D 场景 | `GLTFDocument.write_to_filesystem()` |
| ZIP | `ZIPPacker` 逐文件写入 |

---

## 5. 关键概念详解

### 5.1 运行时加载 vs 导入加载

| 特性 | 运行时加载 | 导入加载 |
|------|------------|----------|
| 文件位置 | 任意路径 | 必须在项目内 |
| 导入流程 | 无需导入 | 需 Godot 导入 |
| 适用场景 | 用户生成内容 | 项目资源 |

### 5.2 关键类

| 类 | 用途 |
|----|------|
| `Image` | 图像加载/保存 |
| `AudioStream*.load_from_file()` | 音频加载 |
| `GLTFDocument` / `FBXDocument` | 3D 场景加载 |
| `FontFile` | 字体加载 |
| `ZIPReader` / `ZIPPacker` | ZIP 读写 |
| `FileAccess` | 通用文件读写 |
