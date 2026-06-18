# 音频设备切换

这是一个演示，展示如何在 Godot 中更改音频输出设备。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2758

## 工作原理

它使用
[`AudioServer`](https://docs.godotengine.org/en/latest/classes/class_audioserver.html)
中的 `set_device()` 方法来更改音频设备。
设备列表通过 `get_device_list()` 填充。

## 截图

![Screenshot](screenshots/device_changer.png)
