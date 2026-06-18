# 插件演示

这里包含多个插件演示，为了方便都放在同一个项目中。

由于[问题 #36713](https://github.com/godotengine/godot/issues/36713)，
你需要先打开项目导入资源一次，然后关闭，再重新打开。

更多信息请参阅[编辑器插件文档](https://docs.godotengine.org/en/latest/tutorials/plugins/editor/index.html)。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2802

# 工作原理

该项目包含 4 个插件：

* 自定义节点插件演示了如何使用 `add_custom_type` 创建自定义节点类型。[更多信息](addons/custom_node)。

* 主屏幕插件是一个关于如何创建带有主屏幕的插件的极简示例。[更多信息](addons/main_screen)。

* 材质创建器插件演示了如何添加具有简单功能的自定义面板，以及如何创建具有自定义加载、保存、导入和导出逻辑的自定义 Resource 类型，包括编辑器集成。[更多信息](addons/material_creator)。

* 简单导入插件演示了如何让一个简单插件处理自定义文件类型（mtxt）的导入。[更多信息](addons/simple_import_plugin)。

要在其他项目中使用这些插件，请将任意一个文件夹复制到 Godot 项目的 `addons/` 文件夹中，
然后在项目设置中启用它们。

例如，路径看起来像这样：`addons/custom_node`

插件可以通过 UI 分发和安装。
如果你制作一个包含该文件夹的 ZIP 压缩包，Godot 会识别它
为插件并允许你安装。

可以通过终端执行：`zip -r custom_node.zip custom_node/*`

## 截图

![心形自定义节点](screenshots/heart_custom_node.webp)

![主屏幕插件](screenshots/main_screen_plugin.webp)

![材质创建器插件](screenshots/material_creator_plugin_applied.webp)

![简单导入插件](screenshots/simple_import_plugin.webp)
