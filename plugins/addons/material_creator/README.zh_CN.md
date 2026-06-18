# 材质创建器插件演示

此插件演示展示了以下内容：

- 如何在 Godot 编辑器中创建具有基本功能的自定义面板。
  自定义面板由 Control 节点组成，它们在编辑器中运行，
  任何行为都必须通过 `@tool` 脚本来实现。
  更多信息请参阅此文档文章：
  https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html#a-custom-dock

- 如何创建自定义 Resource 类型，并提供序列化、
  反序列化和转换此 Resource 类型的逻辑。

- 与加载、保存和导入此 Resource 类型的类的编辑器集成，
  包括可选的导入自定义。

更全面的示例请参见 Godot 源代码中的 GLTF 模块。

更简单的示例请参见"simple_import_plugin"文件夹。

## 导入 vs 加载

此演示中的自定义 Resource 类型由两组不同的编辑器类补充：

- [EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html)
  位于 `importers/` 文件夹中，允许自定义文件
  如何作为不同类型的 Resource 导入到 Godot 中，
  并可选择导入设置。
  导入的文件旁边会生成 `.import` 文件。

- [ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html)
  和 [ResourceFormatSaver](https://docs.godotengine.org/en/stable/classes/class_resourceformatsaver.html)
  位于 `load_and_save/` 文件夹中，允许轻松
  在检查器中编辑文件并保存回去。
  资源文件旁边会生成 `.uid` 文件。

这两种方法是互斥的。
对于给定的文件扩展名，一次只能使用一种方法。
此演示通过使用 2 种不同的文件扩展名来展示这两种方法。

在实际项目中，你应该选择 [EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html) 进行可配置的导入，
或者选择 [ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html) 进行可写的资源加载。
选择取决于你是将文件视为外部源资产，
需要导入并可在导入时自定义
（[EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html)），
还是将文件视为内部 Godot 资源，
旨在在 Godot 内原生直接编辑
（[ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html)）。

例如，glTF 文件可能由 Blender 生成，因此
不打算在 Godot 中直接编辑，所以应使用
[EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html)。
类似地，PNG 文件通常由图像编辑器生成，Godot
需要将其转换为不同的内部格式，如 `.ctex` 文件
用于 VRAM 压缩纹理，所以应使用
[EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html)。
然而，像 `.tres` 和 `.tscn` 这样的文件是 Godot 原生格式，旨在
在 Godot 中直接编辑，所以应使用
[ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html)。

一旦你选择了一种方法，创建派生自相应类的脚本，
重写它们的回调函数，并在你的插件的
[`*_plugin.gd`](material_plugin.gd) 脚本中注册它们。

## 示例文件

[`examples/`](examples/) 文件夹包含几个示例文件：

- `blue.tres`：使用 Godot 内置的 `.tres` 格式直接保存 SillyMaterialResource，
  无需任何自定义加载器/保存器逻辑或导入/导出逻辑，所有 Resource 类型都可用。
  这可以在 Godot 检查器中编辑并保存回去。

- `cyan.silly_mat_loadable`：将 SillyMaterialResource 存储为自定义格式，
  例如通过 [ResourceFormatSaver](https://docs.godotengine.org/en/stable/classes/class_resourceformatsaver.html)，然后使用自定义 [ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html) 加载回来。
  这可以在 Godot 检查器中编辑并保存回去。

- `green_as_standard_mat.silly_mat_importable`：将 SillyMaterialResource 存储为自定义格式，
  使用自定义导入/导出逻辑作为 StandardMaterial3D 导入。这展示了
  导入器如何将文件导入为任何 Resource 类型，将自定义文件转换为 Godot 可以使用的数据。
  导入的文件是只读的，不能在检查器中编辑。

- `yellow.silly_mat_importable`：将 SillyMaterialResource 存储为自定义格式，
  使用自定义导入/导出逻辑作为 SillyMaterialResource 导入。
  导入的文件是只读的，不能在检查器中编辑。

- `yellow_tinted_red.silly_mat_importable`：将 SillyMaterialResource 存储为自定义格式，
  使用自定义导入/导出逻辑作为 SillyMaterialResource 导入。

  - 此文件与 `yellow.silly_mat_importable` 的内容完全相同，但
    对应的 `.import` 文件设置了一个标志，将反照率颜色向红色偏移，
    使材质呈现橙色而非黄色。
    这演示了导入器如何使用导入设置在导入过程中修改数据。
    导入后，导入的文件是只读的，不能在检查器中编辑。

  - 如果你在编辑器中使用"加载导入的材质（EditorImportPlugin）"加载此文件，
    或在 GDScript 中调用 `ResourceLoader.load()`，它将加载导入的版本，
    其中包括红色偏移，因此反照率颜色将是橙色。如果你在编辑器中使用"导入材质（运行时直接导入）"导入此
    文件，或在 GDScript 中调用
    `SillyMaterialResource.read_from_file()`，它将直接读取原始
    文件的内容，忽略导入过程，因此反照率颜色将是黄色。
    这演示了文件如何在 Godot 的导入过程中加载（仅编辑器），
    或完全绕过导入过程（在编辑器和运行时均有效）。

![材质创建器插件导入文件为只读](../../screenshots/material_creator_plugin_imported_file_is_read_only.webp)

## 编辑器按钮

材质创建器面板有以下 6 个按钮：

- "应用材质"：将当前材质应用于编辑器中所有选中的 MeshInstance3D 节点。

- "保存材质（ResourceFormatSaver）"：使用自定义的
  [ResourceFormatSaver](https://docs.godotengine.org/en/stable/classes/class_resourceformatsaver.html)
  将当前材质保存到 `.silly_mat_loadable` 文件，
  或使用 Godot 内置的 ResourceFormatSaverText 保存到 `.tres` 文件。
  这可以在 Godot 检查器中编辑并保存回去。

- "导出材质（运行时直接导出）"：使用 SillyMaterialResource 上的函数
  将当前材质导出到 `.silly_mat_*` 文件。
  这适用于 `res://` 文件夹之外的文件，并且可以在运行时完成。

- "加载材质（ResourceFormatLoader）"：使用自定义的
  [ResourceFormatLoader](https://docs.godotengine.org/en/stable/classes/class_resourceformatloader.html)
  加载 `.silly_mat_loadable` 文件，
  或使用 Godot 内置的 ResourceFormatLoaderText 加载 `.tres` 文件。
  这可以在 Godot 检查器中编辑并保存回去。

- "加载导入的材质（EditorImportPlugin）"：加载由
  [EditorImportPlugin](https://docs.godotengine.org/en/stable/classes/class_editorimportplugin.html)
  导入的 `.silly_mat_importable` 文件。
  加载的数据实际上来自对应的
  导入文件，保存为 `res://.godot/imported/something.silly_mat_importable-hash.res`。
  导入的文件是只读的，不能在检查器中编辑。

- "导入材质（运行时直接导入）"：直接从源文件导入 `.silly_mat_*`，
  按需执行导入，而不是加载编辑器之前导入的数据。
  这会忽略任何编辑器导入设置，适用于 `res://` 文件夹之外的文件，
  并且可以在运行时完成。

![材质创建器插件面板](../../screenshots/material_creator_plugin_dock.webp)
