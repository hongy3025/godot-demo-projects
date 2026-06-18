## 系统操作演示 —— 提供各种操作系统级操作的按钮回调。
##
## 继承自 [Node]，演示 shell 打开、窗口管理、剪贴板、振动、全局菜单等功能。
## Web 平台会自动禁用不支持的按钮。
extends Node


## _ready 入口，检测 Web 平台并禁用不支持的按钮。
func _ready() -> void:
	if OS.has_feature("web"):
		for button: Button in [
			$GridContainer/OpenShellFolder,
			$GridContainer/MoveWindowToForeground,
			$GridContainer/RequestAttention,
			$GridContainer/VibrateDeviceShort,
			$GridContainer/VibrateDeviceLong,
			$GridContainer/AddGlobalMenuItems,
			$GridContainer/RemoveGlobalMenuItem,
			$GridContainer/KillCurrentProcess,
		]:
			button.disabled = true
			button.text += "\n(not supported on Web)"


## 用默认浏览器打开示例网址。
func _on_open_shell_web_pressed() -> void:
	OS.shell_open("https://example.com")


## 在文件管理器中打开用户主目录。
func _on_open_shell_folder_pressed() -> void:
	var path := OS.get_environment("HOME")
	if path == "":
		# Windows 专用
		path = OS.get_environment("USERPROFILE")

	if OS.get_name() == "macOS":
		# macOS 专用
		path = "file://" + path

	OS.shell_show_in_file_manager(path)


## 修改窗口标题。
func _on_change_window_title_pressed() -> void:
	DisplayServer.window_set_title("Modified window title. Unicode characters for testing: é € × Ù ¨")


## 修改窗口图标为纯色图像。
func _on_change_window_icon_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_ICON):
		OS.alert("Changing the window icon is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	var image := Image.create(128, 128, false, Image.FORMAT_RGB8)
	image.fill(Color(1, 0.6, 0.3))
	DisplayServer.set_icon(image)


## 5 秒后将窗口移到前台。
func _on_move_window_to_foreground_pressed() -> void:
	DisplayServer.window_set_title("Will move window to foreground in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_move_to_foreground()
	# 恢复之前的窗口标题
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


## 5 秒后请求窗口注意力。
func _on_request_attention_pressed() -> void:
	DisplayServer.window_set_title("Will request attention in 5 seconds, try unfocusing the window...")
	await get_tree().create_timer(5).timeout
	DisplayServer.window_request_attention()
	# 恢复之前的窗口标题
	DisplayServer.window_set_title(ProjectSettings.get_setting("application/config/name"))


## 短振动（200ms）。
func _on_vibrate_device_short_pressed() -> void:
	Input.vibrate_handheld(200)


## 长振动（1000ms）。
func _on_vibrate_device_long_pressed() -> void:
	Input.vibrate_handheld(1000)


## 添加全局菜单项。
func _on_add_global_menu_items_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_GLOBAL_MENU):
		OS.alert("Global menus are not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	# 在主菜单栏添加菜单
	DisplayServer.global_menu_add_submenu_item("_main", "Hello", "_main/Hello")
	DisplayServer.global_menu_add_item(
			"_main/Hello",
			"World",
			func(tag: String) -> void: print("Clicked main 1 " + str(tag)),
			func(tag: String) -> void: print("Key main 1 " + str(tag)),
			null,
			(KEY_MASK_META | KEY_1) as Key
		)
	DisplayServer.global_menu_add_separator("_main/Hello")
	DisplayServer.global_menu_add_item("_main/Hello", "World2", func(tag: String) -> void: print("Clicked main 2 " + str(tag)))

	# 在 Dock 上下文菜单添加菜单
	DisplayServer.global_menu_add_submenu_item("_dock", "Hello", "_dock/Hello")
	DisplayServer.global_menu_add_item("_dock/Hello", "World", func(tag: String) -> void: print("Clicked dock 1 " + str(tag)))
	DisplayServer.global_menu_add_separator("_dock/Hello")
	DisplayServer.global_menu_add_item("_dock/Hello", "World2", func(tag: String) -> void: print("Clicked dock 2 " + str(tag)))


## 移除全局菜单项。
func _on_remove_global_menu_item_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_GLOBAL_MENU):
		OS.alert("Global menus are not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	DisplayServer.global_menu_remove_item("_main/Hello", 2)
	DisplayServer.global_menu_remove_item("_main/Hello", 1)
	DisplayServer.global_menu_remove_item("_main/Hello", 0)
	DisplayServer.global_menu_remove_item("_main", 0)

	DisplayServer.global_menu_remove_item("_dock/Hello", 2)
	DisplayServer.global_menu_remove_item("_dock/Hello", 1)
	DisplayServer.global_menu_remove_item("_dock/Hello", 0)
	DisplayServer.global_menu_remove_item("_dock", 0)


## 获取剪贴板内容。
func _on_get_clipboard_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		OS.alert("Clipboard I/O is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	OS.alert("Clipboard contents:\n\n%s" % DisplayServer.clipboard_get())


## 设置剪贴板内容。
func _on_set_clipboard_pressed() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		OS.alert("Clipboard I/O is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	DisplayServer.clipboard_set("Modified clipboard contents. Unicode characters for testing: é € × Ù ¨")


## 显示警告对话框。
func _on_display_alert_pressed() -> void:
	OS.alert("Hello from Godot! Close this dialog to resume the main window.")


## 终止当前进程。
func _on_kill_current_process_pressed() -> void:
	OS.kill(OS.get_process_id())
