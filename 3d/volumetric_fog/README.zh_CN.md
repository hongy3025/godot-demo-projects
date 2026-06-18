# 体积雾

这是 Godot 使用 Vulkan 渲染器的体积雾功能示例。

展示的功能包括：

- 影响反照率（入射光）和发射的正/负密度体积。
- 盒体/椭球体形状、高度衰减和使用 3D 纹理的密度调制。
- 时间性重投影，提高稳定性并避免闪烁。
  - 通过移动的雾体积演示差异。
- 全局密度调整。使用具有正密度的 FogVolume 节点，
  可以在特定区域仅应用体积雾。
- 具有实时 3D 噪声的自定义 FogVolume 着色器
  （[由 alghost 提供](https://godotshaders.com/shader/moving-gradient-noise-fog-mist-for-godot-4/)）。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2754

## 截图

![Screenshot](screenshots/volumetric_fog.webp)
