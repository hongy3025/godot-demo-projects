# Simple Import Plugin - 源代码导读

> 本文档面向 Godot 新手，讲解如何创建最简单的编辑器导入插件。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

这是一个极简的 Godot 编辑器导入插件，演示如何处理自定义文件格式（`.mtxt`）的导入。`.mtxt` 文件包含 RGB 颜色值，导入后生成 `StandardMaterial3D`。

---

## 2. 核心架构

```
plugin.cfg → 声明插件元信息
    ↓
plugin.gd → 插件入口，注册导入插件
    ↓
import.gd → 继承 EditorImportPlugin，实现导入逻辑
    ↓
test.mtxt → 示例源文件（内容: "255,0,0"）
```

---

## 3. 文件逐层导读

### `plugin.gd` — 插件入口

```gdscript
@tool
extends EditorPlugin

func _enter_tree() -> void:
    import_plugin = preload("import.gd").new()
    add_import_plugin(import_plugin)

func _exit_tree() -> void:
    remove_import_plugin(import_plugin)
```

### `import.gd` — 导入逻辑 ⭐

```gdscript
@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
    return "demos.mtxt"

func _get_recognized_extensions() -> PackedStringArray:
    return ["mtxt"]

func _get_save_extension() -> String:
    return "res"

func _get_resource_type() -> String:
    return "Material"
```

**`_import()` 核心逻辑：**

```gdscript
func _import(source_file, save_path, options, ...) -> Error:
    var file := FileAccess.open(source_file, FileAccess.READ)
    var line := file.get_line()
    var channels := line.split(",")  # "255,0,0" → ["255", "0", "0"]
    var color := Color8(int(channels[0]), int(channels[1]), int(channels[2]))
    var material := StandardMaterial3D.new()
    if options.use_red_anyway:
        color = Color8(255, 0, 0)
    material.albedo_color = color
    return ResourceSaver.save(material, "%s.%s" % [save_path, _get_save_extension()])
```

**导入选项：** `use_red_anyway` — 勾选后忽略文件中的颜色，强制使用红色。

### `test.mtxt` — 示例文件

```
255,0,0
```

表示红色（R=255, G=0, B=0）。

---

## 4. 关键概念详解

### EditorImportPlugin 必须实现的方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `_get_importer_name()` | `String` | 唯一标识符 |
| `_get_visible_name()` | `String` | 在导入面板中显示的名称 |
| `_get_recognized_extensions()` | `PackedStringArray` | 支持的文件扩展名 |
| `_get_save_extension()` | `String` | 保存的文件扩展名 |
| `_get_resource_type()` | `String` | 生成的资源类型 |
| `_import(...)` | `Error` | 核心导入逻辑 |

### 导入流程

```
1. 用户将 .mtxt 文件放入项目
2. Godot 检测到新文件 → 查找匹配的导入插件
3. 调用 _import() → 读取文件 → 创建材质 → 保存 .res
4. 生成的材质可在 3D 网格上使用
```
