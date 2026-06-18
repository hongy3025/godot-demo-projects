# 2D 多边形和线条

使用 [Polygon2D](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html) 和 [Line2D](https://docs.godotengine.org/en/stable/classes/class_line2d.html) 的实心与纹理 2D 多边形和线条演示。

在此项目中，实心 Line2D 通过使用特制纹理实现抗锯齿。通过使用除顶部和底部边缘（完全透明的白色）外所有像素均为纯白色的纹理，边缘因双线性过滤而显得平滑。该概念的更广泛变体（适用于可变宽度线条）可以在非官方的 [Antialiased Line2D 插件](https://github.com/godot-extended-libraries/godot-antialiased-line2d)中找到。

使用 Forward+ 和 Mobile 渲染方法时也支持 2D 多重采样抗锯齿（MSAA）。这是一种较慢的方法，但适用于视口内执行的所有 2D 绘制，包括 Polygon2D 节点或[自定义绘制](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html)。此方法可以与上述 Line2D 抗锯齿技术同时使用。

语言：GDScript

渲染器：Mobile

## 截图

![截图](screenshots/polygons_lines.webp)
