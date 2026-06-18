# 文本转语音演示

这是一个展示文本转语音支持的演示。

语言：GDScript

渲染器：Compatibility

在资源库中查看此演示：https://godotengine.org/asset-library/asset/2763

## 工作原理

它使用 [`DisplayServer`](https://docs.godotengine.org/en/latest/classes/class_displayserver.html) 单例的 `tts_*()` 方法
来枚举语音信息、向操作系统 TTS API 发送文本，并接收回调信号。

## 截图

![Screenshot](screenshots/text_to_speech.webp)
