# 计算着色器高度图

此演示项目展示了如何在 Godot 中使用*计算着色器*。
计算着色器是一段在 GPU 上运行的代码，使用 GLSL 编写
（与
[Godot 着色器语言](https://docs.godotengine.org/en/latest/tutorials/shaders/shader_reference/index.html)
不同）。

计算着色器可以利用 GPU 执行大规模并行操作比 CPU 更快的优势。此演示可以从噪声纹理生成岛屿的高度图，
既可以在 CPU 上也可以在 GPU 上生成。您可以尝试两种选项来比较在 CPU 和 GPU 上生成高度图所需的时间。

对于较小的噪声纹理，CPU 通常更快，但纹理越大，使用 GPU 的优势越明显。
在配备 NVIDIA GeForce RTX 3060 和
第 11 代 Intel Core i7 处理器的 PC 上，测试表明计算着色器在纹理尺寸为 1024×1024 及以上时更快。

图像的尺寸可以通过主场景上的导出属性 **Dimensions** 设置。
默认设置为 2048，即创建 2048×2048 的高度图。

> [!NOTE]
>
> 着色器代码已结构化，以便用户逐步理解，
> 可能并不代表最佳实践。CPU 代码也没有进行尽可能的优化。
> 这是为了尽可能与 GPU 代码保持一致。除了使用 GPU 之外，没有使用多线程。

语言：GDScript, GLSL

渲染器：Mobile

![Compute Shader Heightmap](screenshots/heightmap.webp)
