# 音频 BPM 同步

演示如何将音频播放与时间同步以实现一致的 BPM。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2757

## 工作原理

对于声音时钟，它使用
[`AudioServer`](https://docs.godotengine.org/en/latest/classes/class_audioserver.html)
中的方法来同步音频播放。
对于系统时钟，它使用 `OS.get_ticks_usec()`。

## 截图

![Screenshot](screenshots/bpm.png)
