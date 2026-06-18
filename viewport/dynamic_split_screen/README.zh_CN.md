# 动态分屏

此示例项目展示了动态分屏的实现，
也称为 Voronoi 分屏。

语言：[Godot 着色器语言](https://docs.godotengine.org/en/latest/tutorials/shaders/shader_reference/shading_language.html) 和 GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2806

## 详情

动态分屏系统在两个玩家靠近时显示单个屏幕，
当他们分开时显示分割视图。

分割线可以根据玩家的位置呈现任意角度，
因此不会是垂直或水平的。

该系统由乐高视频游戏推广开来。

## 工作原理

两个摄像头放置在两个独立的视口中，它们的
纹理以及其他一些参数被传递给
一个附加到填满整个屏幕的 TextureRect 上的着色器。

`SplitScreen` 着色器在 `CameraController` 脚本的帮助下，
选择每个像素显示哪个纹理以实现效果。

摄像头放置在连接两个玩家的线段上，
如果他们足够靠近则放在中间，否则放在固定距离处。

## 使用方法

在 Godot 引擎中打开并启动项目，然后
使用 WASD 移动第一个玩家（红色），使用 IJKL（或方向键）
移动第二个玩家（蓝色）。

`camera_controller.gd` 脚本设置了参数，用于调整屏幕分割的
距离以及分割线的宽度和颜色。

## 截图

![截图](screenshots/dynamic_split_screen.webp)
