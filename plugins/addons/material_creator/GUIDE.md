# Material Creator Plugin - 源代码导读

> 本文档面向 Godot 新手，讲解如何创建自定义 Resource 类型、自定义 Dock、以及导入/导出系统。

---

## 目录

1. [项目概述](#1-项目概述)
2. [核心架构](#2-核心架构)
3. [文件逐层导读](#3-文件逐层导读)
4. [关键概念详解](#4-关键概念详解)

---

## 1. 项目概述

这是一个功能完整的 Godot 编辑器插件，演示了：
- 创建自定义 `Resource` 类型（`SillyMaterialResource`）
- 添加自定义 Dock 面板
- 实现自定义文件格式的加载/保存
- 实现编辑器导入插件（ImportPlugin）

---

## 2. 核心架构

```
material_plugin.gd → 插件入口，注册所有组件
    ├── SillyMaterialResource → 自定义资源类型
    ├── SillyMatFormatLoader → 文件加载器
    ├── SillyMatFormatSaver → 文件保存器
    ├── ImportSillyMatAsSillyMaterialResource → 导入为自定义资源
    ├── ImportSillyMatAsStandardMaterial3D → 导入为标准材质
    └── material_dock.tscn → 自定义 Dock 面板
```

---

## 3. 文件逐层导读

### `silly_material_resource.gd` — 自定义资源 ⭐

```gdscript
@tool
class_name SillyMaterialResource
extends Resource

@export var albedo_color: Color = Color.BLACK
@export var metallic_strength: float = 0.0
@export var roughness_strength: float = 0.0
```

**关键方法：**

| 方法 | 用途 |
|------|------|
| `from_json_dictionary(dict)` | 从 JSON 字典读取 → 新 `SillyMaterialResource` |
| `to_json_dictionary()` | 转为 JSON 字典 → 用于保存 |
| `from_material(mat)` | 从 `StandardMaterial3D` 复制属性 |
| `to_material()` | 生成新的 `StandardMaterial3D` |
| `read_from_file(path)` | 从 `.silly_mat_loadable` 文件读取 |
| `write_to_file(path)` | 写入 `.silly_mat_loadable` 文件 |

**数据流：**

```
.silly_mat_importable 文件 (JSON 格式)
    ↓ ImportPlugin
SillyMaterialResource 或 StandardMaterial3D
    ↓
可在 3D 网格上使用
```

### `material_plugin.gd` — 插件入口

```gdscript
func _enter_tree() -> void:
    ResourceLoader.add_resource_format_loader(_silly_mat_loader)
    ResourceSaver.add_resource_format_saver(_silly_mat_saver)
    add_import_plugin(_import_as_silly_mat_res)
    add_import_plugin(_import_as_standard_mat)
    add_control_to_dock(DOCK_SLOT_LEFT_UL, _material_creator_dock)
```

**注册了 4 个系统：**

| 组件 | 类型 | 文件扩展名 |
|------|------|-----------|
| `SillyMatFormatLoader` | `ResourceFormatLoader` | `.silly_mat_loadable` |
| `SillyMatFormatSaver` | `ResourceFormatSaver` | `.silly_mat_loadable` |
| `ImportSillyMatAsSillyMaterialResource` | `EditorImportPlugin` | `.silly_mat_importable` |
| `ImportSillyMatAsStandardMaterial3D` | `EditorImportPlugin` | `.silly_mat_importable` |

### Dock 面板 (`editor/material_dock.tscn`)

允许用户在编辑器中：
1. 选择颜色（Albedo Color）
2. 调整金属度和粗糙度
3. 应用到选中的 3D 网格
4. 保存/加载到文件

---

## 4. 关键概念详解

### 加载器 vs 导入器

| | 加载器 (`ResourceFormatLoader`) | 导入器 (`EditorImportPlugin`) |
|---|---|---|
| 时机 | 运行时 + 编辑器 | 仅编辑器导入时 |
| 文件是否被复制 | 否，直接读取源文件 | 是，导入到 `.import` 目录 |
| 结果是否可写 | 是 | 否（只读） |
| 典型用途 | 自定义数据格式 | 贴图、模型等资产 |

### 自定义 Resource 的序列化

`@export` 变量自动支持 Inspector 编辑和 `.tres`/`.res` 序列化。额外的 JSON 序列化通过 `to_json_dictionary` / `from_json_dictionary` 实现。
