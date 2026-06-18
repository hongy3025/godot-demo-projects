# XR 旁观者视图演示

这是一个 OpenXR 项目的演示，其中玩家在头戴设备内看到的视图
与旁观者在屏幕上看到的视图不同。
当部署到独立 XR 设备时，仅导出玩家环境。

语言：GDScript

渲染器：Compatibility, Mobile

> [!NOTE]
>
> 此演示需要 Godot 4.5.1 或更高版本

## 工作原理

VR 游戏本身包含在 `main.tscn` 场景中。这与本仓库中的其他 XR 演示类似。
此演示有一个极简的示例，以免分散我们在此展示的解决方案的注意力。

在独立 VR 头戴设备上运行时，将加载该场景。
![项目设置](screenshots/project_setup_main_scene.png)

在桌面上运行时，我们改为加载 `spectator.tscn` 场景（以前称为 `construct.tscn`）。此场景将 `main.tscn` 场景作为
`SubViewport` 的子节点，该视口将用于将渲染结果输出到头戴设备。

![构造场景](screenshots/construct_scene.png)

旁观者场景还包含一个 `SubviewportContainer` 和一个 `SubViewport`，用于渲染用户
在桌面屏幕上看到的输出。
默认情况下，这将显示一个第三人称摄像头，展示我们的玩家。

我们还按如下方式配置了视觉层：
1. 第 1 层在头戴设备内和第三人称摄像头中都可见。
2. 第 2 层仅在头戴设备内可见。
3. 第 3 层仅在第三人称摄像头中可见。
这用于仅在旁观者视图中渲染玩家的"头部"。

最后，一个下拉菜单还允许我们切换到：
- 显示第三人称摄像头视图，
- 显示第一人称摄像头视图，但带有稳定的摄像头，
- 显示玩家看到的左眼或右眼结果（仅限兼容渲染器）。

## 追踪摄像头

演示中还有一个选项可以启用摄像头追踪。
目前仅在 SteamVR 上配合正确配置的 HTC Vive Tracker 支持。

正确设置后，这允许你使用 Vive 追踪器来定位第三人称摄像头。
将 Vive 追踪器附加到物理摄像头上，并设置正确的偏移量，可以
通过将第三人称渲染结果与绿幕摄像头捕获相结合来实现混合现实捕获。

## 摄像头定位

如果摄像头追踪不可用，我们的旁观者摄像头将看向我们的玩家。
玩家可以使用激光指示器指向摄像头，按住扳机，然后移动摄像头。

激光指示器可以在左手或右手上激活。
最后按下按钮的手将成为活动手。

## 动作映射

此项目不使用默认的动作映射，而是配置了一个仅包含此示例所需动作的动作映射。这样我们可以去除所有杂乱内容，专注于所展示的功能。

此示例使用以下动作：
- aim_pose 用于瞄准指示器
- interact 用于与指向的对象交互

另外，按照 OpenXR 指南，仅提供项目测试过的控制器的绑定。XR 运行时应该提供适当的重新映射，但并非所有运行时都遵循此指南。你可能需要为你使用的平台向动作映射添加绑定。

## 在 PCVR 上运行

此项目专为 PCVR 设计。确保已安装 OpenXR 运行时。
此项目已使用 Oculus 客户端和 SteamVR OpenXR 运行时测试。
请注意，Godot 目前无法使用 WMR OpenXR 运行时运行。请安装带 WMR 支持的 SteamVR。

## 在独立 VR 上运行

此项目还展示了部署到独立设备时如何跳过旁观者视图选项。
你必须安装 Android 构建模板和 [OpenXR vendors 插件](https://github.com/GodotVR/godot_openxr_vendors/releases)，并为你的设备配置导出模板。
请按照[手册中关于部署到 Android 的说明](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html)操作。

## 截图

![截图](screenshots/spectator_view_demo.png)
