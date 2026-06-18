# Pong（C#）

一个简单的 Pong 游戏。本示例展示了 Godot 游戏开发的最佳实践，
包括[信号](https://docs.godotengine.org/en/latest/getting_started/step_by_step/signals.html)。

语言：[C#](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/index.html)

渲染器：Compatibility

> [!NOTE]
>
> GDScript 版本可在此处获取：[链接](https://github.com/godotengine/godot-demo-projects/tree/master/2d/pong)。

在资源库中查看此示例：https://godotengine.org/asset-library/asset/2796

## 工作原理

墙壁、球拍和球都是
[`Area2D`](https://docs.godotengine.org/en/latest/classes/class_area2d.html)
节点。当球碰到墙壁或球拍时，
它们会发射信号并修改球的状态。

## 截图

![截图](screenshots/pong.png)
