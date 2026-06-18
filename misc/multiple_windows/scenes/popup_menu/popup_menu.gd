## 弹出菜单演示 —— 展示 PopupMenu 的各种菜单项类型。
##
## 继承自 [PopupMenu]，演示普通项、多状态项、单选检查项、复选检查项、
## 分隔符、子菜单等所有菜单项类型。
extends PopupMenu


## 选项被选中时发出的信号，携带选项文本
signal option_pressed(option: String)


## _ready 入口，添加各种类型的菜单项。
func _ready() -> void:
	add_item("Normal Item")
	add_multistate_item("Multistate Item", 3, 0)
	add_radio_check_item("Radio Check Item 1")
	add_radio_check_item("Radio Check Item 2")
	add_check_item("Check Item")
	add_separator("Separator")
	add_submenu_item("Submenu", "SubPopupMenu")
	var submenu: PopupMenu = $SubPopupMenu
	submenu.transparent = true
	submenu.add_item("Submenu Item 1")
	submenu.add_item("Submenu Item 2")
	submenu.index_pressed.connect(func(index): option_pressed.emit(submenu.get_item_text(index)))
	index_pressed.connect(_on_index_pressed)


## 菜单项选中回调，处理检查项的状态切换。
func _on_index_pressed(index: int) -> void:
	if is_item_checkable(index):
		set_item_checked(index, not is_item_checked(index))

	match index:
		2:
			set_item_checked(3, false)
		3:
			set_item_checked(2, false)

	option_pressed.emit(get_item_text(index))
