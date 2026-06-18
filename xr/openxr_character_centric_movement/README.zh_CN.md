# XR 角色主体中心移动演示

这是一个 OpenXR 项目的演示，其中玩家移动使用 CharacterBody3D 作为基础节点处理。
这基于[房间规模手册页面中解释的角色主体中心解决方案](https://docs.godotengine.org/en/stable/tutorials/xr/xr_room_scale.html#character-body-centric-solution)。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2809

## 工作原理

使用现代 VR 设备，用户可以在一个大的游戏空间内移动。
这通常被称为房间规模 VR。
头戴设备和控制器的位置是相对于该游戏空间内的一个固定点进行追踪的。
这通常是用户设置守护系统时划定的游戏空间中心地面上的一个点。

在 Godot 中，该游戏空间的中心由 `XROrigin3D` 节点表示，摄像头和控制器分别通过 `XRCamera3D` 和 `XRController3D` 子节点进行追踪，因此用户不能定位它们。
这在处理玩家移动时引起的误解在 [XR 房间规模手册页面](https://docs.godotengine.org/en/stable/tutorials/xr/xr_room_scale.html)中有详细描述，强烈建议在继续此演示之前阅读。

此演示实现了玩家移动问题的角色主体中心解决方案。
此演示中玩家的虚拟移动（例如通过控制器输入的移动）与非 XR Godot 游戏的处理方式类似。
玩家的物理移动将导致角色主体尝试移动到玩家的新位置。
如果成功，XROrigin 节点将向玩家移动的相反方向移动。
如果不成功，角色主体将停留在原地，玩家移动得越远，屏幕就越暗。

## 动作映射

此项目不使用默认的动作映射，而是配置了一个仅包含此示例所需动作的动作映射。这样我们可以去除所有杂乱内容，专注于所展示的功能。

此示例只需要两个动作：
- aim_pose 用于定位 XR 控制器
- move 用作移动的输入

"移动"是这里的主角。此动作仅绑定到两个控制器之一，默认情况下是右手选项。Godot 始终将移动动作与绑定到的控制器关联。

代码示例假设任一控制器都可以触发移动动作。从右手切换到左手是一个单独的话题，不在本演示的讨论范围内。

另外，按照 OpenXR 指南，仅提供项目测试过的控制器的绑定。XR 运行时应该提供适当的重新映射，但并非所有运行时都遵循此指南。你可能需要为你使用的平台向动作映射添加绑定。

## 在 PCVR 上运行

此项目可以像普通 PCVR 项目一样运行。确保已安装 OpenXR 运行时。
此项目已使用 Oculus 客户端和 SteamVR OpenXR 运行时测试。
请注意，Godot 目前无法使用 WMR OpenXR 运行时运行。请安装带 WMR 支持的 SteamVR。

## 在独立 VR 上运行

你必须安装 Android 构建模板和 OpenXR 加载器插件，并为你的设备配置导出模板。
请按照[手册中关于部署到 Android 的说明](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html)操作。

## 截图

![截图](screenshots/character_movement_demo.png)
