## 双向文本与字体特性演示 —— 展示 Godot 的 BiDi（双向文本）、可变字体和系统字体功能。
## 继承自 [Control]，包含三个功能标签页：文本方向、可变字体、系统字体。
extends Control

## 可变字体预览的 FontVariation 引用，用于动态调整字体轴参数。
@onready var variable_font_variation: FontVariation = $"TabContainer/Variable fonts/VariableFontPreview".get_theme_font(&"font")


## _ready 入口：初始化各标签页的 UI 状态。
## Web 平台不支持系统字体加载，隐藏相关控件。
func _ready() -> void:
	if OS.has_feature("web"):
		$"TabContainer/System fonts/LabelVarInfo".text = "Loading system fonts is not supported on the Web platform."
		$"TabContainer/System fonts/ValueSetter".visible = false
		$"TabContainer/System fonts/Italic".visible = false
		$"TabContainer/System fonts/Weight".visible = false
		$"TabContainer/System fonts/VBoxContainer".visible = false

	# 初始化文本方向标签页的树形控件，展示希伯来语 RTL 文本。
	var tree: Tree = $"TabContainer/Text direction/Tree"
	var root := tree.create_item()
	tree.set_hide_root(true)
	var first := tree.create_item(root)
	first.set_text(0, "רֵאשִׁית")
	var second := tree.create_item(first)
	second.set_text(0, "שֵׁנִי")
	var third := tree.create_item(second)
	third.set_text(0, "שְׁלִישִׁי")
	var fourth := tree.create_item(third)
	fourth.set_text(0, "fourth")


## 树形控件项选中回调：将选中项的路径显示在带/不带结构化文本的 LineEdit 中。
func _on_Tree_item_selected() -> void:
	var tree: Tree = $"TabContainer/Text direction/Tree"
	var path: String = ""
	var item := tree.get_selected()
	while item != null:
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	$"TabContainer/Text direction/LineEditST".text = path
	$"TabContainer/Text direction/LineEditNoST".text = path


## 自定义结构化文本目标输入框文本变化回调：同步到源输入框。
func _on_LineEditCustomSTDst_text_changed(new_text: String) -> void:
	$"TabContainer/Text direction/LineEditCustomSTSource".text = new_text


## 自定义结构化文本源输入框文本变化回调：同步到目标输入框。
func _on_LineEditCustomSTSource_text_changed(new_text: String) -> void:
	$"TabContainer/Text direction/LineEditCustomSTDst".text = new_text


## 自定义结构化文本目标输入框进入场景回调：加载完成后刷新文本以应用自定义脚本。
func _on_LineEditCustomSTDst_tree_entered() -> void:
	$"TabContainer/Text direction/LineEditCustomSTDst".text = $"TabContainer/Text direction/LineEditCustomSTSource".text


## 可变字体大小滑块变化回调：更新字体大小（非可变字体也支持此属性）。
func _on_variable_size_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Size/Value".text = str(value)
	$"TabContainer/Variable fonts/VariableFontPreview".add_theme_font_size_override(&"font_size", value)


## 可变字体粗细滑块变化回调：更新字重轴（weight）参数。
## 需要复制字典再赋值才能使可变字体轴值生效。
func _on_variable_weight_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Weight/Value".text = str(value)
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["weight"] = value
	variable_font_variation.variation_opentype = dict


## 可变字体倾斜滑块变化回调：更新倾斜轴（slant）参数。
func _on_variable_slant_value_changed(value: float) -> void:
	$"TabContainer/Variable fonts/Variables/Slant/Value".text = str(value)
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["slant"] = value
	variable_font_variation.variation_opentype = dict


## 可变字体手写体开关回调：更新自定义手写体轴（custom_CRSV）参数。
func _on_variable_cursive_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Cursive".button_pressed = button_pressed
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_CRSV"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


## 可变字体随意体开关回调：更新自定义随意体轴（custom_CASL）参数。
func _on_variable_casual_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Casual".button_pressed = button_pressed
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_CASL"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


## 可变字体等宽开关回调：更新自定义等宽轴（custom_MONO）参数。
func _on_variable_monospace_toggled(button_pressed: bool) -> void:
	$"TabContainer/Variable fonts/Variables/Monospace".button_pressed = button_pressed
	var dict := variable_font_variation.variation_opentype.duplicate()
	dict["custom_MONO"] = int(button_pressed)
	variable_font_variation.variation_opentype = dict


## 系统字体预览文本变化回调：更新所有系统字体标签的显示文本。
func _on_system_font_value_text_changed(new_text: String) -> void:
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		label.text = new_text


## 系统字体粗细滑块变化回调：更新所有系统字体标签的字重。
func _on_system_font_weight_value_changed(value: float) -> void:
	$"TabContainer/System fonts/Weight/Value".text = str(value)
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		var system_font: SystemFont = label.get_theme_font(&"font")
		system_font.font_weight = int(value)


## 系统字体斜体开关回调：更新所有系统字体标签的斜体设置。
func _on_system_font_italic_toggled(button_pressed: bool) -> void:
	for label: Label in [
		$"TabContainer/System fonts/VBoxContainer/SansSerif/Value",
		$"TabContainer/System fonts/VBoxContainer/Serif/Value",
		$"TabContainer/System fonts/VBoxContainer/Monospace/Value",
		$"TabContainer/System fonts/VBoxContainer/Cursive/Value",
		$"TabContainer/System fonts/VBoxContainer/Fantasy/Value",
		$"TabContainer/System fonts/VBoxContainer/Custom/Value"
	]:
		var system_font: SystemFont = label.get_theme_font(&"font")
		system_font.font_italic = button_pressed


## 系统字体名称输入框文本变化回调：更新自定义系统字体的字体名称。
func _on_system_font_name_text_changed(new_text: String) -> void:
	var system_font: SystemFont = $"TabContainer/System fonts/VBoxContainer/Custom/FontName".get_theme_font(&"font")
	system_font.font_names[0] = new_text
