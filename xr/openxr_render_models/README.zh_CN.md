# OpenXR 渲染模型演示

这是一个展示 OpenXR 渲染模型实现的演示。

语言：GDScript

渲染器：Compatibility

> [!NOTE]
>
> 此演示需要 Godot 4.5 或更高版本

## 截图

![截图](screenshots/render_model_demo.png)

## 工作原理

OpenXR 允许我们在不了解正在使用的硬件的情况下运行应用程序，
或者在我们开发应用程序时无法访问这些硬件。

因此，我们没有直接的信息告诉我们正在使用什么硬件，
但在某些情况下，我们希望直观地显示这些硬件。

这特别适用于用户使用的控制器，因为显示正确的硬件
可以提高用户的沉浸感。

渲染模型 API 允许我们枚举当前正在使用的设备，然后查询
信息，如它的 3D 资产、它在空间中的位置和方向，以及
资产各个组件的位置和方向。

Godot 的实现通过 OpenXRRenderModelManager 节点隐藏了大部分复杂性，
该节点作为 XROrigin3D 节点的子节点。你可以单独添加这个节点，让它显示
所有当前活动的渲染模型，或者像我们在此演示中所做的那样，你可以
在每个控制器的树中添加节点来显示与该控制器相关的渲染模型。

## 动作映射

此演示项目有一个极简的动作映射，因为我们只处理定位。

## 在 PCVR 上运行

此项目可以像普通 PCVR 项目一样运行。确保已安装 OpenXR 运行时。

## 在独立 VR 上运行

你必须安装 Android 构建模板和 OpenXR 加载器插件，并为你的设备配置导出模板。
请按照[手册中关于部署到 Android 的说明](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html)操作。
