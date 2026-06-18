# 物理插值

此演示展示了在 3D 中使用不同摄像机模式（第一人称、第三人称、固定视角）的
[物理插值](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/index.html)。
这也被称为*固定时间步长插值*。

物理插值使运动看起来平滑，无论渲染帧率和
项目设置中配置的物理滴答率如何。然而，其使用存在一些注意事项，
例如延迟增加和传送物体的潜在问题。建议在项目中启用物理插值时
仔细阅读
[文档](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html)。

物理插值在此项目中默认启用。在演示运行时按 <kbd>T</kbd>
可切换其开关。这允许你观察物理插值对
平滑度的影响。

语言：GDScript

渲染器：Compatibility

## 截图

![Screenshot](screenshots/physics_interpolation.webp)
