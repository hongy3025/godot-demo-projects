# 层次化有限状态机

本示例展示如何在 GDScript 中应用状态机编程模式，包括层次化状态和下推自动机。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2714

## 为什么要使用状态机

状态在游戏中很常见。你可以使用该模式来：

1. 分离每个行为及行为之间的转换，从而使脚本更短、更易于管理。

2. 遵循单一职责原则。每个状态对象代表一个动作。

3. 改善代码结构。查看场景树和文件系统选项卡：无需查看代码，你就能知道玩家可以做什么或不能做什么。

你可以在优秀的
[游戏编程模式电子书](https://gameprogrammingpatterns.com/state.html)中阅读更多关于状态的内容。

## 截图

![截图](screenshots/fsm-attack.png)
