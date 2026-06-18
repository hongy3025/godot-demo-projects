# 大世界坐标

本项目展示了可选的双精度渲染和物理支持的实际应用。

使用*单精度*构建时，一旦你距离世界原点超过几千个单位，精度误差就会变得明显。

使用*双精度*构建时，即使距离世界原点非常远（数十亿个单位或更远），网格仍将保持稳定。

更多信息请参见
[大世界坐标文档](https://docs.godotengine.org/en/latest/tutorials/physics/large_world_coordinates.html)。

> **警告**
>
> 出于性能原因，官方 Godot 构建**未**启用双精度支持。
> 你需要编译自定义引擎构建才能使用双精度支持。

语言：GDScript

渲染器：Mobile

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2786

## 截图

![未使用双精度引擎构建的大世界坐标](screenshots/large_world_coordinates_single_precision_build.webp)

![使用双精度引擎构建的大世界坐标](screenshots/large_world_coordinates_double_precision_build.webp)
