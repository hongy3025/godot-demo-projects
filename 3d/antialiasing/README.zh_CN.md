# 3D 抗锯齿

本项目展示了 Godot 支持的多种 [3D 抗锯齿](https://docs.godotengine.org/en/latest/tutorials/3d/3d_antialiasing.html) 技术。

- **多重采样抗锯齿 (MSAA)：** 质量高，性能开销大。不会造成图像模糊。
  - 对着色器导致的锯齿（如高光锯齿）或 Alpha 裁剪材质无效，这些部分仍会呈现锯齿。
- **快速近似抗锯齿 (FXAA)：** 质量低，性能开销小。会轻微模糊图像。
- **子像素形态抗锯齿 (SMAA)：** 质量中等，性能开销适中。会轻微模糊图像，但程度低于 FXAA。Godot 仅支持 SMAA 的空间版本（亦称 SMAA 1x）。
- **时域抗锯齿 (TAA)：** 质量高，性能开销小。会轻微模糊图像（但程度低于 FXAA）。
  - 快速移动物体的抗锯齿质量不如其他方法，尤其在低帧率下，因为 TAA 来不及在这些物体上收敛。启用 TAA 后可使用 FPS 限制功能，在不同帧率下对比画质（前提是显卡性能足够）。
  - 可能在移动物体上引入鬼影，尤其是当材质着色器未正确生成运动矢量时。
- **超采样抗锯齿 (SSAA)：** 质量最高，但开销也最大。不会造成图像模糊。
  - 200% 分辨率缩放等效于 4× SSAA，即每个维度均放大一倍。例如，在 1920×1080 窗口下以 200% 渲染比例运行时，3D 帧缓冲区的分辨率为 3840×2160。
  - SSAA 可与 FXAA 或 TAA 联用，在抵消后两者带来的模糊的同时，进一步提升抗锯齿质量。
- **Alpha 抗锯齿：** 应用于演示中的特定材质，提供两种模式（Alpha 边缘混合与 Alpha 边缘裁剪）。启用 MSAA 时效果最佳，此时 Godot 会在材质上启用 Alpha-to-Coverage 渲染。禁用 MSAA 时，材质透明区域边缘将应用固定抖动图案。

Godot 允许同时使用多种抗锯齿技术，有助于获得最佳画质或在性能上取得更优平衡。

此外还提供了分辨率缩放滑块。当缩放比例低于 100% 时，可启用 AMD FidelityFX Super Resolution 1.0 上采样以改善画质，效果优于传统双线性插值。

> **注意**
>
> AMD FidelityFX Super Resolution 1.0 **并非**抗锯齿技术，建议与其他抗锯齿方法配合使用。

语言：GDScript

渲染器：Forward+

## 截图

![Screenshot](screenshots/antialiasing.webp)

## 许可

`polyhaven/` 目录中的文件下载自 <https://polyhaven.com/a/dutch_ship_medium>，采用 CC0 1.0 通用许可协议。
