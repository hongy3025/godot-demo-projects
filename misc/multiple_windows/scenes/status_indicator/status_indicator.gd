## 状态指示器 —— 系统托盘图标管理。
##
## 继承自 [StatusIndicator]，提供系统托盘图标和右键菜单。
## 左键点击恢复窗口，右键菜单包含退出选项。
extends StatusIndicator


## 弹出菜单引用（通过节点路径获取）
@onready var popup_menu: PopupMenu = get_node(menu)


## _ready 入口，初始化弹出菜单并连接信号。
func _ready() -> void:
	popup_menu.prefer_native_menu = true
	popup_menu.add_item("Quit")
	popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	pressed.connect(_on_pressed)


## 左键点击回调，恢复窗口并获取焦点。
func _on_pressed(mouse_button: int, _mouse_position: Vector2i) -> void:
	if mouse_button == MOUSE_BUTTON_LEFT:
		var window: Window = get_window()
		if window.mode == Window.Mode.MODE_MINIMIZED:
			window.mode = Window.Mode.MODE_WINDOWED
		window.grab_focus()


## 弹出菜单项选择回调。
func _on_popup_menu_index_pressed(index: int) -> void:
	match index:
		0:
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
