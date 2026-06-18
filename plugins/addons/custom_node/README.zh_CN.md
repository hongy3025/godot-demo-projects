# 自定义节点插件演示

此插件演示展示了在 Godot 中创建自定义节点类型的一种方法。
更多信息请参阅此文档文章：https://docs.godotengine.org/en/latest/tutorials/plugins/editor/making_plugins.html#a-custom-node

自定义节点类型：

* 派生自现有节点类型。

* 在添加新节点时显示在类型列表中。

* 附加有脚本以添加新行为。

* 可以拥有自定义图标。

此插件的工作方式是在插件脚本文件中使用 `add_custom_type` 和 `remove_custom_type`。
使用此方法，你可以为自定义节点指定任意名称、基础类型、脚本和图标。

还有另一种添加自定义节点类型的方法，即在脚本中使用 `class_name` 关键字，
或[在 C# 中的类声明上方使用 `[GlobalClass]` 属性](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_global_classes.html)。
