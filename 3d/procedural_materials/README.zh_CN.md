# 程序化材质

此演示包含使用 3 种不同技术生成的程序化材质：

- **[NoiseTexture2D](https://docs.godotengine.org/en/stable/classes/class_noisetexture2d.html)：**
  内置类，基于噪声模式（如 Simplex 或 Cellular）
  在 CPU 上生成图像。仅适用于静态纹理。
  纹理生成是异步完成的，并且比使用脚本更快，
  因为噪声算法在引擎中是用 C++ 实现的。

- **脚本：** 使用
  [Image](https://docs.godotengine.org/en/stable/classes/class_image.html) 类
  在 CPU 上程序化生成
  [ImageTexture](https://docs.godotengine.org/en/stable/classes/class_imagetexture.html)。
  仅适用于静态纹理。这种方法比 NoiseTexture2D 更灵活，
  但生成纹理速度较慢。一旦纹理生成，
  渲染性能与 NoiseTexture2D 相同。

- **着色器：** 在匹配
  [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html) 大小的
  [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html)
  节点上使用 2D 着色器，并将生成的
  [ViewportTexture](https://docs.godotengine.org/en/stable/classes/class_viewporttexture.html)
  应用于材质。这在 GPU 上实时更新，最适合
  动画纹理。这种方法也可用于静态纹理，
  由于不需要每帧更新纹理，性能开销更低。

语言：GDScript

渲染器：Forward+

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2749

## 截图

![Screenshot](screenshots/procedural_materials.webp)
