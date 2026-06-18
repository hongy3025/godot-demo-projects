# 全局光照

此演示展示了 Godot 的全局光照系统：
LightmapGI、VoxelGI、SDFGI、ReflectionProbe 以及屏幕空间效果如 SSAO 和 SSIL。

使用鼠标环顾四周，使用 <kbd>W</kbd>/<kbd>A</kbd>/<kbd>S</kbd>/<kbd>D</kbd>
或方向键移动。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2737

## 工作原理

一个球体和一个盒子作为摄像机的子节点，用于展示动态物体光照。
一个 ReflectionProbe 作为球体的子节点，用于展示实时反射。
当 ReflectionProbe 隐藏时，它被禁用。在这种情况下，
将使用 VoxelGI、SDFGI 或环境光照来提供回退反射。

一个 Decal 节点作为移动球体和立方体的子节点，为它们提供简单的阴影。
这在使用 LightmapGI（全部）全局光照模式时特别有效，
因为该模式不允许动态物体在静态表面上投射阴影。

## 截图

![Screenshot](screenshots/global_illumination.png)

## 许可

`zdm2.glb` 衍生自 [Cube 2: Sauerbraten](http://sauerbraten.org/)
地图 "zdm2"，并根据 [CC BY 4.0 Unported 许可](https://github.com/Calinou/game-maps-obj/blob/master/sauerbraten/zdm2.txt)。
其转换来源的 OBJ 文件可在 [game-maps-obj](https://github.com/Calinou/game-maps-obj) 仓库中找到。
