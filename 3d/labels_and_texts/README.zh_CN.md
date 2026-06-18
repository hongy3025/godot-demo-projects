# 3D 标签和文本

该项目展示了 Godot 支持的两种主要 3D 文本技术：
Label3D 和 TextMesh。

Label3D 和 TextMesh 都存在于 3D 空间中，并且可以选择被
其他物体遮挡，但它们服务于不同的用例。

**Label3D：** Label3D 节点与其他任何 3D 节点一样。它使用
每个字符一个四边形来绘制文本，可以选择设置为公告板模式。

**TextMesh：** 与 Label3D 不同，TextMesh 可以选择具有实际深度，因为它
生成几何体来表示文本。TextMesh 不是一个节点，而是一个
在 MeshInstance3D 节点中使用的 PrimitiveMesh 资源。因此，
你不会在"创建新节点"对话框中看到 TextMesh。

图标也可以使用图标字体在 Label3D 和 TextMesh 中显示，这些图标字体
可以使用诸如 [Fontello](https://fontello.com/) 之类的服务从 SVG 文件生成。
请注意，虽然 Label3D 支持彩色
光栅化字体（如 emoji），但 Fontello 只能生成单色字体。
TextMesh 和使用 MSDF 字体的 Label3D 也仅限于单色字体。

标准光栅化字体和 MSDF 字体都可以在 Label3D 中使用，而 TextMesh
只支持可以很好地绘制为 MSDF 的字体。这排除了具有
自相交轮廓的字体，Godot 目前无法很好地处理将其转换为 MSDF。

在大多数情况下，Label3D 更易于使用并且看起来更好（得益于
轮廓和 MSDF 渲染）。TextMesh 更强大，适用于更专业化的用例。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2740

## 截图

![Screenshot](screenshots/3d_labels_and_texts.png)
