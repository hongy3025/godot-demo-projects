# 2D 自定义绘制

演示如何在不使用节点的情况下在 Godot 中绘制 2D 元素。这可用于创建程序化图形、执行调试绘制以帮助排查游戏逻辑问题，或通过不为每个可见元素创建节点来提高性能。

抗锯齿可以通过两种方式实现：启用某些 CanvasItem `draw_*` 方法提供的 `antialiasing` 参数，或在项目设置中启用 2D MSAA。2D MSAA 通常较慢，但它适用于任何类型的基于线条或基于多边形的 2D 绘制，即使对于不支持 `antialiasing` 参数的 `draw_*` 方法也是如此。请注意，2D MSAA 仅在 Forward+ 和 Mobile 渲染器中可用，Compatibility 渲染器不支持。

更多信息请参阅文档中的
[2D 自定义绘制](https://docs.godotengine.org/en/latest/tutorials/2d/custom_drawing_in_2d.html)。

语言：GDScript

渲染器：Mobile

## 截图

![截图](screenshots/custom_drawing.webp)
