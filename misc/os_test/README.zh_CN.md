# 操作系统测试

此演示展示了 Godot 中各种操作系统相关的功能。
可用于在将 Godot 移植到新平台时进行测试，或检查回归问题。

简而言之，此演示展示了如何从操作系统获取信息，或与操作系统进行交互。

语言：GDScript 和部分 [C#](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/index.html)
（运行此演示**不**需要 .NET 构建）

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2789

## 工作原理

[`OS`](https://docs.godotengine.org/en/latest/classes/class_os.html)
类提供了平台相关代码的抽象层。
OS 封装了与主机操作系统通信的最常用功能，例如剪贴板、视频驱动、日期和时间、
定时器、环境变量、二进制文件执行、命令行等。

按钮连接到带有 `actions.gd` 脚本的节点，该脚本使用 OS 类执行操作。
左侧的文本使用 `os_test.gd` 脚本填充，该脚本使用 OS 类收集有关操作系统的信息。

在启用了 Mono 的 Godot 版本上，Godot 会将 `MonoTest.cs` 加载到
`MonoTest` 节点中。然后，由
[`C# 预处理器定义`](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/c_sharp_features.html#preprocessor-defines)
确定的信息将被添加到左侧面板。

## 截图

![顶部 HiDPI](screenshots/top-hidpi.png)

![Mono](screenshots/mono.png)
