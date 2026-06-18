# XR 绑定修饰器演示

这是一个 OpenXR 项目的演示，展示了如何在动作映射中使用绑定修饰器功能。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/0000

## 工作原理

OpenXR 引入了一个称为绑定修饰器的系统，允许你向动作映射添加额外的逻辑。
目前只有两个修饰器可用，但未来可能会有更多。

**警告：** 绑定修饰器是需要启用的可选功能，可能并非在所有平台上都可用。

## 本地地板参考空间

此演示使用本地地板参考空间，因此玩家默认居中面向信息显示屏。

如果你的玩家没有站在正确的位置，请尝试系统重置中心。
不同运行时的操作不同，例如：
- 在 Quest 上（包括使用 SteamLink），按住 Meta 按钮 3 秒可触发重置中心。
- 在 SteamVR 上，打开头戴设备内的 SteamVR 菜单，从菜单中选择重置中心选项。

## 动作映射

此项目不使用默认的动作映射，而是配置了一个仅包含此示例所需动作的动作映射。这样我们可以去除所有杂乱内容，专注于所展示的功能。

动作映射中定义的动作仅用于演示不同的修饰器，并使用 `grip_pose` 来定位控制器。

### 模拟阈值修饰器

这是一个作用于由模拟控制（如扳机或握持按钮，在某些控制器上）驱动的布尔输入的修饰器。
使用此修饰器，你可以更改输入从 `true` 切换为 `false` 或反之的默认值。

![截图](screenshots/analog_binding_modifier.png)

**注意：** 此修饰器是在各个绑定上使用每个绑定旁边的修饰器按钮创建的。

### DPad 修饰器

DPad 扩展将常见的输入（如摇杆和触控板）拆分为类似 DPad 的输入。
使用 DPad 输入时，不应再绑定原始的摇杆或触控板输入。
你也可以选择添加修饰器来进一步控制此行为。

![截图](screenshots/dpad_modifier.png)

**注意：** 此修饰器是在交互配置文件中使用右侧的修饰器按钮创建的。

## 在 PCVR 上运行

此项目可以像普通 PCVR 项目一样运行。确保已安装 OpenXR 运行时。
此项目已使用 Oculus 客户端和 SteamVR OpenXR 运行时测试。
请注意，Godot 目前无法使用 WMR OpenXR 运行时运行。请安装带 WMR 支持的 SteamVR。

## 在独立 VR 上运行

你必须安装 Android 构建模板和 OpenXR 加载器插件，并为你的设备配置导出模板。
请按照[手册中关于部署到 Android 的说明](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html)操作。

## 截图

![截图](screenshots/binding_modifier_demo.png)
