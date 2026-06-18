# GUI 翻译演示

这是一个演示如何实现项目国际化的示例。翻译内容创建在 CSV 文件中，然后导入到 Godot 中。

为了正确显示，所使用的字体必须包含目标语言所需的字形。请参阅 `fonts` 文件夹，了解一些可以在项目中使用的字体。Godot 可以加载系统字体作为后备方案，但这并非在所有平台上都受支持，而且系统字体的不同视觉设计可能会造成不一致。

Godot 允许在修改区域设置时自动更改国际化文本。资源也可以设置为国际化替代版本，并在区域设置更改时自动替换。此过程称为*重映射*。

同时展示了 CSV 和 gettext（PO/POT）两种方法。使用右下角的按钮在两种方法之间切换。

使用 PO 的资源重映射过程与 CSV 相同。游戏内文本翻译过程也相同——使用键来获取相应的翻译。

PO 文件和 CSV 文件之间的主要区别在于两者存储翻译数据的方式。请查看 `translations/po` 和 `translations/csv` 文件夹以了解相关文件。

更多信息请参阅[国际化游戏](https://docs.godotengine.org/en/latest/tutorials/i18n/internationalizing_games.html)和[使用 gettext 进行本地化](https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html)。

语言：GDScript

渲染器：Compatibility

## 截图

![Screenshot](screenshots/translation.webp)