# 2.5D 演示项目（GDScript）

此演示项目展示了如何在 Godot 中通过混合 2D 和 3D 节点来创建 2.5D 游戏。它还添加了一个 2.5D 编辑器视口，方便编辑 2.5D 关卡。

语言：GDScript

渲染器：Compatibility

> [!NOTE]
>
> 另有 C# 版本，可参见[此处](https://github.com/godotengine/godot-demo-projects/tree/master/mono/2.5d)。

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2783

## 工作原理

通过 Godot 插件添加自定义节点类型以支持 2.5D 对象。Node25D 是所有 2.5D 对象的基类。其第一个子节点必须是一个 3D Spatial 节点，用于计算位置。然后，添加一个 2D Sprite（或类似节点）来显示对象。

在 Node25D 内部，使用由三个 `Vector2` 组成的 2.5D 变换矩阵，将 3D 位置计算为 2D 位置。本项目使用 CharacterBody 和 StaticBody（3D）来获取 3D 位置，但这些仅用于数学计算——摄像机是 2D 的，所有精灵也是 2D 的。你可以使用任何 Spatial 节点进行数学计算。

实现了多种视角模式，包括俯视、正面、45 度、等距以及两种斜角模式。要实现不同的视角，只需在 Node25D 中创建一组新的基向量，将其应用于所有实例，并创建相应的 2D 精灵来显示对象即可。

该插件还添加了 YSort25D 用于对 Node25D 节点进行排序，以及 ShadowMath25D 用于计算阴影（一个尝试向下投射的简单 CharacterBody）。

## 截图

![四十五度](screenshots/forty_five.png)

![等距](screenshots/isometric.png)

![斜角 Z](screenshots/oblique_z.png)

![斜角 Y](screenshots/oblique_y.png)

![正面](screenshots/front_side.png)

![立方体](screenshots/cube.png)

![2.5D 编辑器视口](screenshots/editor.png)

## 音乐许可

`assets/mr_mrs_robot.ogg` 版权所有 &copy; 约 2008 年 Juan Linietsky，CC-BY：署名。
