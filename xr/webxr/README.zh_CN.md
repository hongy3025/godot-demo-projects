# WebXR 演示

这是一个 WebXR 渲染和控制器支持的极简演示。

导出到 Web 平台时，请确保包含 WebXR Polyfill 和 WebXR Layers Polyfill，它们将填补 Web 浏览器中 WebXR 支持的空白。
要包含这些 polyfill，请打开**导出**窗口，将以下代码复制到 Web 导出预设的 `Head Include` 字段中：

```html
<script src="https://cdn.jsdelivr.net/npm/webxr-polyfill@latest/build/webxr-polyfill.min.js"></script>
<script>
var polyfill = new WebXRPolyfill();
</script>
<script src="https://cdn.jsdelivr.net/npm/webxr-layers-polyfill@latest/build/webxr-layers-polyfill.min.js"></script>
<script>
var layersPolyfill = new WebXRLayersPolyfill();
</script>
```

语言：GDScript

渲染器：Compatibility
