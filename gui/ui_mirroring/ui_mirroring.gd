## UI 镜像演示 —— 展示 Godot 的 RTL（从右到左）界面镜像功能。
## 继承自 [Control]，通过切换语言环境（阿拉伯语/英语）来演示 UI 的自动镜像布局。
extends Control


## _ready 入口：显示当前语言环境的名称。
func _ready() -> void:
	$Label.text = TranslationServer.get_locale()


## 按钮点击回调：在阿拉伯语和英语之间切换语言环境。
## 阿拉伯语是 RTL（从右到左）语言，切换后 UI 会自动镜像布局。
func _on_Button_pressed() -> void:
	if TranslationServer.get_locale() != "ar":
		TranslationServer.set_locale("ar")
	else:
		TranslationServer.set_locale("en")

	$Label.text = TranslationServer.get_locale()
