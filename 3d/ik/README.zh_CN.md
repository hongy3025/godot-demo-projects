# 3D 反向动力学

这是在 Godot 中实现的不同反向动力学算法的示例。
它包含四个场景，展示了它们的不同使用方式。

语言：GDScript

渲染器：Forward+

## 工作原理

此演示展示了如何使用两种不同的方法实现 IK。一种使用 Godot 内置的
[`SkeletonIK3D`](https://docs.godotengine.org/en/latest/classes/class_skeletonik3d.html)
节点。另一种方法使用名为 FABRIK（在 SADE 插件中）的脚本
来实现反向动力学。

## 截图

![Screenshot](screenshots/cube.png)

![Screenshot](screenshots/fps_gun.png)
