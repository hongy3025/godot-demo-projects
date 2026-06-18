## 序列化示例 GUI —— 管理存档/读档界面的初始状态。
## 继承自 [VBoxContainer]，作为 UI 布局容器。
## 在 _ready 时检查存档文件是否存在，决定是否启用加载按钮。
extends VBoxContainer


## 节点就绪时调用。检查存档文件是否存在，禁用不存在的存档对应的加载按钮。
func _ready() -> void:
	# 不允许加载不存在的文件
	($SaveLoad/LoadConfigFile as Button).disabled = not FileAccess.file_exists("user://save_config_file.ini")
	($SaveLoad/LoadJSON as Button).disabled = not FileAccess.file_exists("user://save_json.json")


## "打开用户数据文件夹"按钮的信号回调。
## 使用操作系统默认的文件管理器打开 Godot 的 user:// 目录。
func _on_open_user_data_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))
