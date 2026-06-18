# 音频生成器

这是一个演示，展示如何从 GDScript 生成并播放音频样本。
它播放一个简单的 440 Hz 正弦波，采样率为 22050 Hz。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2759

## 工作原理

它使用
[`AudioStreamGeneratorPlayback`](https://docs.godotengine.org/en/latest/classes/class_audiostreamgeneratorplayback.html)
对象（位于
[`AudioStreamPlayer`](https://docs.godotengine.org/en/latest/classes/class_audiostreamplayer.html)
节点内）的 `push_frame()` 方法，基于 `pulse_hz` 逐帧生成音频。
