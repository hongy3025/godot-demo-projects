## 多窗口演示 —— 主场景控制器。
##
## 继承自 [Control]，管理子窗口、对话框、弹出菜单等所有 UI 组件。
## 演示 Window、FileDialog、AcceptDialog、ConfirmationDialog、Popup 等用法。
extends Control


@onready var window: Window = $Window
@onready var draggable_window: Window = $DraggableWindow
@onready var file_dialog: FileDialog = $FileDialog
@onready var file_dialog_output: TextEdit = $HBoxContainer/VBoxContainer2/FileDialogOutput
@onready var accept_dialog: AcceptDialog = $AcceptDialog
@onready var accept_dialog_output: TextEdit = $HBoxContainer/VBoxContainer2/AcceptOutput
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var confirmation_dialog_output: TextEdit = $HBoxContainer/VBoxContainer2/ConfirmationOutput
@onready var popup: Popup = $Popup
@onready var popup_menu: PopupMenu = $PopupMenu
@onready var popup_menu_output: TextEdit = $HBoxContainer/VBoxContainer3/PopupMenuOutput
@onready var popup_panel: PopupPanel = $PopupPanel
@onready var status_indicator: StatusIndicator = $StatusIndicator


## 嵌入子窗口切换回调。
func _on_embed_subwindows_toggled(toggled_on: bool) -> void:
	var hidden_windows: Array[Window] = []
	for child in get_children():
		if child is Window and child.is_visible():
			child.hide()
			hidden_windows.append(child)

	embed_subwindows(toggled_on)
	for _window in hidden_windows:
		_window.show()


## 设置子窗口嵌入模式。
func embed_subwindows(state: bool) -> void:
	get_viewport().gui_embed_subwindows = state


## 显示基础窗口。
func _on_window_button_pressed() -> void:
	window.show()
	window.grab_focus()


## 切换窗口的 transient 属性。
func _on_transient_window_toggled(toggled_on: bool) -> void:
	window.transient = toggled_on


## 切换窗口的 exclusive 属性。
func _on_exclusive_window_toggled(toggled_on: bool) -> void:
	window.exclusive = toggled_on


## 切换窗口的 unresizable 属性。
func _on_unresizable_window_toggled(toggled_on: bool) -> void:
	window.unresizable = toggled_on


## 切换窗口的 borderless 属性。
func _on_borderless_window_toggled(toggled_on: bool) -> void:
	window.borderless = toggled_on


## 切换窗口的 always_on_top 属性。
func _on_always_on_top_window_toggled(toggled_on: bool) -> void:
	window.always_on_top = toggled_on


## 切换窗口的 transparent 属性。
func _on_transparent_window_toggled(toggled_on: bool) -> void:
	window.transparent = toggled_on


## 窗口标题编辑回调。
func _on_window_title_edit_text_changed(new_text: String) -> void:
	window.title = new_text


## 显示可拖拽窗口。
func _on_draggable_window_button_pressed() -> void:
	draggable_window.show()
	draggable_window.grab_focus()


## 隐藏可拖拽窗口。
func _on_draggable_window_close_pressed() -> void:
	draggable_window.hide()


## 切换可拖拽窗口的背景可见性。
func _on_bg_draggable_window_toggled(toggled_on: bool) -> void:
	draggable_window.get_node(^"BG").visible = toggled_on


## 鼠标穿透多边形选项选择回调。
func _on_passthrough_polygon_item_selected(index: int) -> void:
	match index:
		0:
			draggable_window.mouse_passthrough_polygon = []
		1:
			draggable_window.get_node(^"PassthroughGenerator").generate_polygon()
		2:
			draggable_window.mouse_passthrough_polygon = [
					Vector2(16, 0), Vector2(16, 128),
					Vector2(116, 128), Vector2(116, 0)]


## 显示文件对话框。
func _on_file_dialog_button_pressed() -> void:
	file_dialog.show()


## 文件对话框选择目录回调。
func _on_file_dialog_dir_selected(dir: String) -> void:
	file_dialog_output.text = "Directory Path: " + dir


## 文件对话框选择单个文件回调。
func _on_file_dialog_file_selected(path: String) -> void:
	file_dialog_output.text = "File Path: " + path


## 文件对话框选择多个文件回调。
func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	file_dialog_output.text = "Chosen Paths: " + str(paths)


## 文件对话框模式选择回调。
func _on_file_dialog_options_item_selected(index: int) -> void:
	match index:
		0:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		1:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
		2:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		3:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
		4:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE


## 切换原生对话框。
func _on_native_dialog_toggled(toggled_on: bool) -> void:
	file_dialog.use_native_dialog = toggled_on


## 接受对话框自定义按钮文本提交。
func _on_accept_button_text_submitted(new_text: String) -> void:
	if not new_text.is_empty():
		accept_dialog.add_button(new_text, false, new_text)


## 接受对话框取消回调。
func _on_accept_dialog_canceled() -> void:
	accept_dialog_output.text = "Cancelled"


## 接受对话框确认回调。
func _on_accept_dialog_confirmed() -> void:
	accept_dialog_output.text = "Accepted"


## 接受对话框自定义操作回调。
func _on_accept_dialog_custom_action(action: StringName) -> void:
	accept_dialog_output.text = "Custom Action: " + action
	accept_dialog.hide()


## 显示接受对话框。
func _on_accept_button_pressed() -> void:
	accept_dialog.show()


## 显示确认对话框。
func _on_confirmation_button_pressed() -> void:
	confirmation_dialog.show()


## 确认对话框取消回调。
func _on_confirmation_dialog_canceled() -> void:
	confirmation_dialog_output.text = "Cancelled"


## 确认对话框确认回调。
func _on_confirmation_dialog_confirmed() -> void:
	confirmation_dialog_output.text = "Accepted"


## 在鼠标位置显示弹出窗口。
func show_popup(_popup: Popup):
	var mouse_position
	if get_viewport().gui_embed_subwindows:
		mouse_position = get_global_mouse_position()
	else:
		mouse_position = DisplayServer.mouse_get_position()

	_popup.popup(Rect2(mouse_position, _popup.size))


## 显示 Popup。
func _on_popup_button_pressed() -> void:
	show_popup(popup)


## 显示 PopupMenu。
func _on_popup_menu_button_pressed() -> void:
	show_popup(popup_menu)


## 显示 PopupPanel。
func _on_popup_panel_button_pressed() -> void:
	show_popup(popup_panel)


## PopupMenu 选项选中回调。
func _on_popup_menu_option_pressed(option: String) -> void:
	popup_menu_output.text = option + " was pressed."


## 状态指示器可见性切换回调。
func _on_status_indicator_visible_toggled(toggled_on: bool) -> void:
	status_indicator.visible = toggled_on
