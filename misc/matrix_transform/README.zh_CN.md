# 矩阵变换

此演示项目是一个可视化变换工作原理的游乐场。

请勿"运行"此项目。你只应在 Godot 编辑器中使用它。

更多信息请参见[矩阵与变换](https://docs.godotengine.org/en/latest/tutorials/math/matrices_and_transforms.html)文章。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2787

## 工作原理

在 2D 和 3D 中，都会绘制彩色线条来表示基向量和原点向量。对于 3D，这意味着长方体。如果你平移、旋转、缩放或剪切 AxisMarker 对象，你将看到它如何影响变换的分量向量，并且所有子对象也会相应地变换。

建议你在主视口和检查器中操作 AxisMarker 对象。建议你在层级结构中复制它们，并按任意方式设置父子关系。

在 2D 中，红色和绿色线条代表 X 轴和 Y 轴，蓝色代表原点。

在 3D 中，红色、绿色和蓝色线条代表 X 轴、Y 轴和 Z 轴，青色代表原点。

一个值得注意的实现细节：为避免抖动，原点向量是一个节点的父节点，并继承 AxisMarker 父节点的变换。

## 截图

![2D](screenshots/2D.png)

![3D](screenshots/3D.png)
