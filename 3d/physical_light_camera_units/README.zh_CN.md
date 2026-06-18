# 物理光照和摄像机单位

此演示展示了
[物理光照和摄像机单位](https://docs.godotengine.org/en/latest/tutorials/3d/physical_light_and_camera_units.html)
的设置。这允许你使用真实世界的单位来表示光照（流明、勒克斯、开尔文）
和摄像机（快门速度、光圈、ISO 感光度）。

默认情况下，Godot 对许多适用于光照的物理属性使用任意单位，
如颜色、能量、摄像机视野和曝光。这些
属性使用任意单位，因为使用精确的物理单位会带来
一些权衡，对于许多游戏来说不值得。由于 Godot 开箱即用更注重易用性，
物理光照单位默认是禁用的。

如果你的项目追求照片级真实感，使用真实世界单位作为基础
可以帮助使调整更容易。真实世界材质、
光照和场景亮度的参考信息在诸如
[Physically Based](https://physicallybased.info/) 等网站上广泛可用。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2746

## 截图

![Screenshot](screenshots/physical_light_camera_units.webp)
