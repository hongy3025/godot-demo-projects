# Plugin Demos - 源代码导读

> 本文档面向 Godot 新手，逐层剖析插件系统的实现原理与代码逻辑。

---

## 目录

1. [项目概述](#1-项目概述)
2. [快速上手](#2-快速上手)
3. [核心架构](#3-核心架构)
4. [文件逐层导读](#4-文件逐层导读)
5. [关键概念详解](#5-关键概念详解)
6. [场景树全景](#6-场景树全景)
7. [如何扩展](#7-如何扩展)

---

## 1. 项目概述

这是一个 **Godot 4.6** 的编辑器插件技术演示项目，包含 4 个独立的插件示例：

| 插件 | 路径 | 说明 |
|------|------|------|
| **自定义节点** | `addons/custom_node/` | 使用 `add_custom_type` 创建自定义节点类型 |
| **主屏幕插件** | `addons/main_screen/` | 创建带主屏幕的编辑器插件 |
| **材质创建器** | `addons/material_creator/` | 自定义 Dock、自定义 Resource 类型、导入/导出 |
| **简单导入插件** | `addons/simple_import_plugin/` | 处理自定义文件类型（mtxt）的导入 |

---

## 2. 快速上手

在 Godot 中打开 `project.godot`，运行主场景 `test_scene.tscn`。编辑器加载后，4 个插件会自动启用（在 `project.godot` 的 `[editor_plugins]` 中配置）。

---

## 3. 核心架构

### 3.1 插件生命周期

```
Godot 编辑器启动
    ↓
读取 project.godot 中 enabled 的插件列表
    ↓
加载每个插件的 plugin.cfg → 找到入口脚本
    ↓
调用 _enter_tree() → 插件注册自身功能
    ↓
编辑器运行中...
    ↓
插件被禁用/卸载 → 调用 _exit_tree() → 清理资源
```

### 3.2 每个插件的标准结构

```
addons/plugin_name/
├── plugin.cfg        ← 插件元信息（名称、作者、入口脚本）
├── plugin.gd         ← 入口脚本，继承 EditorPlugin
├── ...               ← 其他资源文件
```

---

## 4. 文件逐层导读

### 4.1 自定义节点插件 (`addons/custom_node/`)

#### `heart_plugin.gd` — 插件入口

```gdscript
@tool
extends EditorPlugin

func _enter_tree() -> void:
    add_custom_type("Heart", "Node2D", preload("heart.gd"), icon)

func _exit_tree() -> void:
    remove_custom_type("Heart")
```

**核心 API：** `add_custom_type(type, base, script, icon)` — 在编辑器中注册一个新的节点类型。

#### `heart.gd` — 自定义节点脚本

```gdscript
@tool
extends Node2D

func _draw() -> void:
    draw_texture(HEART_TEXTURE, -HEART_TEXTURE.get_size() / 2)
```

`@tool` 使脚本在编辑器中运行。`_draw()` 在编辑器中实时渲染心形图标。

### 4.2 主屏幕插件 (`addons/main_screen/`)

#### `main_screen_plugin.gd` — 插件入口

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_has_main_screen()` | 返回 `true`，告诉编辑器该插件有主屏幕 |
| `_make_visible(visible)` | 控制主面板的显隐 |
| `_get_plugin_name()` | 返回插件名称，显示在编辑器顶部 |
| `_handles(object)` | 判断是否处理某个对象（选中时触发） |

#### `main_panel.tscn` — 主面板场景

包含一个 `PrintHello` 按钮，点击时打印 `"Hello from the main screen plugin!"`。

### 4.3 材质创建器插件 (`addons/material_creator/`)

#### `material_plugin.gd` — 插件入口

**注册了 4 个组件：**

1. **`SillyMatFormatLoader`** — 加载 `.silly_mat_loadable` 文件
2. **`SillyMatFormatSaver`** — 保存到 `.silly_mat_loadable` 文件
3. **`ImportSillyMatAsSillyMaterialResource`** — 导入为自定义资源
4. **`ImportSillyMatAsStandardMaterial3D`** — 导入为标准材质

同时添加了一个自定义 Dock 面板（`material_dock.tscn`），用于在编辑器中创建材质。

#### `silly_material_resource.gd` — 自定义资源类型 ⭐

**类名：** `SillyMaterialResource`（通过 `class_name` 注册）

**关键方法：**

| 方法 | 作用 |
|------|------|
| `from_json_dictionary(dict)` | 从 JSON 字典读取数据 |
| `to_json_dictionary()` | 将数据转为 JSON 字典 |
| `from_material(mat)` | 从 `StandardMaterial3D` 转换 |
| `to_material()` | 生成 `StandardMaterial3D` |
| `read_from_file(path)` | 从文件读取 |
| `write_to_file(path)` | 写入文件 |

**数据流：**

```
.silly_mat_importable 文件
    ↓ (ImportPlugin)
SillyMaterialResource 或 StandardMaterial3D
    ↓
编辑器中使用 / 运行时加载
```

### 4.4 简单导入插件 (`addons/simple_import_plugin/`)

#### `import.gd` — 导入逻辑

继承 `EditorImportPlugin`，处理 `.mtxt` 文件格式。

**关键方法：**

| 方法 | 作用 |
|------|------|
| `_get_importer_name()` | 返回导入器唯一名称 |
| `_get_recognized_extensions()` | 返回识别的文件扩展名 |
| `_get_save_extension()` | 返回保存的扩展名 |
| `_import(source_file, ...)` | 核心导入逻辑 |

**导入流程：**

```
test.mtxt (内容: "255,0,0")
    ↓
FileAccess 读取 → 按逗号分割 → 解析 RGB
    ↓
创建 StandardMaterial3D → 设置 albedo_color
    ↓
ResourceSaver.save() → 保存为 .res 文件
```

**导入选项：** `use_red_anyway` — 勾选后强制使用红色。

---

## 5. 关键概念详解

### 5.1 EditorPlugin 生命周期

| 阶段 | 方法 | 说明 |
|------|------|------|
| 启用 | `_enter_tree()` | 注册功能、添加 UI |
| 禁用 | `_exit_tree()` | 清理资源、移除 UI |
| 主屏幕 | `_has_main_screen()` | 是否有独立主屏幕 |
| 选择处理 | `_handles(object)` | 是否处理选中对象 |

### 5.2 自定义 Resource 类型

使用 `class_name` 声明类名，继承 `Resource`，配合 `@export` 让属性在 Inspector 中可见。实现 `from_json_dictionary` / `to_json_dictionary` 支持序列化。

### 5.3 导入插件 vs 加载器

| 类型 | 时机 | 用途 |
|------|------|------|
| `EditorImportPlugin` | 编辑器导入时 | 将源文件转换为 Godot 资源 |
| `ResourceFormatLoader` | 运行时 | 直接加载自定义格式文件 |

---

## 6. 场景树全景

### 测试场景 `test_scene.tscn`

```
TestScene (Node)
├── Heart (Node2D)              ← 自定义节点，显示心形
├── MeshInstance3D              ← 3D 网格（用于材质测试）
├── HandledByMainScreen (Node)  ← 主屏幕插件处理的对象
└── DirectionalLight3D          ← 3D 光照
```

---

## 7. 如何扩展

### 7.1 创建新插件

1. 在 `addons/` 下创建文件夹
2. 创建 `plugin.cfg` 和入口脚本
3. 在 `project.godot` 的 `[editor_plugins]` 中添加
4. 实现 `_enter_tree()` 和 `_exit_tree()`

### 7.2 添加自定义节点

```gdscript
add_custom_type("MyNode", "Node2D", my_script, my_icon)
```

### 7.3 添加自定义导入格式

继承 `EditorImportPlugin`，实现 `_get_recognized_extensions()` 和 `_import()`。
