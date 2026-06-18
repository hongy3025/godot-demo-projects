# GDScript 版 Pong

一个简单的 Pong 游戏。本演示展示了 Godot 游戏开发的最佳实践，包括[信号](https://docs.godotengine.org/en/latest/getting_started/step_by_step/signals.html)。

语言：GDScript

渲染器：Compatibility

> [!NOTE]
>
> 此处提供 C# 版本：https://github.com/godotengine/godot-demo-projects/tree/master/mono/pong

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2728

## 工作原理

墙壁、球拍和球都是 [`Area2D`](https://docs.godotengine.org/en/latest/classes/class_area2d.html) 节点。当球碰到墙壁或球拍时，它们会发射信号并修改球。

## 截图

![截图](screenshots/pong.png)
