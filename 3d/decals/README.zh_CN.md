# 贴花

此演示包含许多 Decal 节点在运行中的示例，
用于展示 Godot 的渲染能力。

可以在左上角调整贴花过滤模式：

- 对于具有像素艺术外观的游戏，可以使用 Nearest 过滤模式
  代替 Linear。
- 带 Mipmap 的过滤模式可防止贴花在远处看起来有颗粒感，但会带来
  轻微的性能开销。当使用 mipmap 而没有各向异性过滤时，
  贴花在倾斜角度观看时会显得模糊。
- 带各向异性的过滤模式在远处不会出现颗粒感，并且在倾斜角度观看时
  也能避免模糊。然而，带各向异性的过滤模式
  比仅启用 Mipmap 有更大的性能开销。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2736

## 截图

![Screenshot](screenshots/decals.png)
