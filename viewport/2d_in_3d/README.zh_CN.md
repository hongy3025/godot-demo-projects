# 2D 在 3D 中

演示如何使用视口在 3D 场景中显示 2D 场景。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2803

## 工作原理

Pong 游戏被渲染到一个自定义的
[`Viewport`](https://docs.godotengine.org/en/latest/classes/class_viewport.html)
节点，而不是主视口。在代码中，
对 Viewport 调用 `get_texture()` 以获取
[`ViewportTexture`](https://docs.godotengine.org/en/latest/classes/class_viewporttexture.html)，
然后将其分配给四边形材质的反照率纹理。

## 截图

![截图](screenshots/2d_in_3d.webp)
