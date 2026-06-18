# 运行时文件保存与加载

本项目展示了如何在不经过 Godot 资源导入系统的情况下加载和保存各种文件类型。

这对于在运行时加载/保存图像、声音、3D 场景和 ZIP 存档（例如用户生成内容）非常有用，无需用户通过 Godot 生成 PCK 文件。

可以在运行时加载和保存：

- 图像（JPEG、PNG、WebP）
- 3D 场景（glTF 2.0）
- ZIP 存档
- 纯文本文件[^1]

可以在运行时加载：

- 图像（TGA、BMP、SVG[^2]）
- 3D 场景（FBX[^3]）
- 音频（Ogg Vorbis、MP3、WAV）
- 字体（TTF、OTF、WOFF、WOFF2、PFB、PFM、BMFont）

[^1]: 可以使用 FileAccess 和 PackedByteArray 类操作自定义二进制格式，但此演示中未展示。

[^2]: 可以使用 FileAccess 类以编程方式生成 SVG 文本并保存为 `.svg` 扩展名的文件，但此演示中未展示。

[^3]: 运行时 FBX 加载存在已知问题，如问题 [#96043](https://github.com/godotengine/godot/issues/96043) 中所述。

有关保存/加载游戏进度的示例，请参阅[保存与加载（序列化）](../serialization/)演示。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2779

## 截图

![Screenshot](screenshots/runtime_save_load.webp)

## 许可

- `examples/3d_scenes/gltf/` 中的文件版权归 [Poly Haven](https://polyhaven.com/a/plastic_monobloc_chair_01) 所有，采用 [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) 许可。
- `examples/audio/` 中的文件版权归 [Red Eclipse](https://www.redeclipse.net/) 所有，采用 [CC BY-SA 4.0 International](https://www.creativecommons.org/licenses/by-sa/4.0/) 许可。