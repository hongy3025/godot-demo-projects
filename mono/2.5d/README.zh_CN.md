# 2.5D 示例项目（C#）

本示例项目展示了如何通过混合 2D 和 3D 节点在 Godot 中创建 2.5D 游戏。
它还添加了一个 2.5D 编辑器视口，方便编辑 2.5D 关卡。

语言：[C#](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/index.html) 和少量 GDScript

渲染器：Compatibility

> [!NOTE]
>
> GDScript 版本可在此处获取：[链接](https://github.com/godotengine/godot-demo-projects/tree/master/misc/2.5d)。

## 工作原理

在 Godot 插件中添加了自定义节点类型以支持 2.5D 对象。Node25D 是所有 2.5D 对象的基础。它的第一个子节点必须是 3D Spatial 节点，用于计算其位置。然后添加 2D Sprite（或类似节点）来显示对象。

在 Node25D 内部，使用名为 Basis25D 和 Transform25D 的新结构体从 3D 位置计算 2D 位置。为了获取 3D 位置，本项目使用 CharacterBody 和 StaticBody（3D），但这些仅用于数学计算——摄像机是 2D 的，所有精灵也是 2D 的。你可以使用任何 Spatial 节点进行数学计算。

实现了多种视角模式，包括俯视、正面、45 度、等距和两种斜角模式。要实现不同的视角，只需创建一个新的 Basis25D，在所有 Node25D 变换中使用它，并创建相应的 2D 精灵来显示对象。

该插件还添加了 YSort25D 用于排序 Node25D 节点，以及 ShadowMath25D 用于计算阴影（一个简单的 CharacterBody，尝试向下投射阴影）。

## 截图

![四十五度](../../misc/2.5d/screenshots/forty_five.png)

![等距](../../misc/2.5d/screenshots/isometric.png)

![Z 轴斜角](../../misc/2.5d/screenshots/oblique_z.png)

![Y 轴斜角](../../misc/2.5d/screenshots/oblique_y.png)

![正面](../../misc/2.5d/screenshots/front_side.png)

![立方体](../../misc/2.5d/screenshots/cube.png)

![2.5D 编辑器视口](../../misc/2.5d/screenshots/editor.png)

## 音乐许可

`assets/mr_mrs_robot.ogg` 版权所有 &copy; 约 2008 Juan Linietsky，CC-BY：署名。
