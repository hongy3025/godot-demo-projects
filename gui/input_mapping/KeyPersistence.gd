## 按键映射持久化 —— 自动加载的单例（Autoload），用于保存和加载按键映射。
## 继承自 [Node]，通过字典以简单方式持久化按键映射数据。
extends Node

## 按键映射文件的存储路径，使用 user:// 前缀表示用户数据目录。
const keymaps_path: String = "user://keymaps.dat"
## 存储所有按键动作及其对应输入事件的字典。
var keymaps: Dictionary


## _ready 入口：启动时创建按键映射字典并加载已保存的映射。
## 遍历所有输入动作，将每个动作的第一个事件存入字典。
func _ready() -> void:
	for action in InputMap.get_actions():
		if not InputMap.action_get_events(action).is_empty():
			keymaps[action] = InputMap.action_get_events(action)[0]

	load_keymap()


## 从文件加载按键映射。
## 如果保存文件不存在，则创建一个新的保存文件。
## 加载时会逐项检查，确保只加载当前游戏中仍然有效的动作，避免旧版本数据导致问题。
func load_keymap() -> void:
	if not FileAccess.file_exists(keymaps_path):
		# 没有保存文件，创建一个新的。
		save_keymap()
		return

	var file := FileAccess.open(keymaps_path, FileAccess.READ)
	var temp_keymap: Dictionary = file.get_var(true)
	file.close()
	# 不直接替换 keymaps 字典，因为如果游戏更新后删除/添加了动作，
	# 保存文件中可能包含无效的动作。所以逐项检查确保 keymaps 字典包含所有当前动作。
	for action: StringName in keymaps.keys():
		if temp_keymap.has(action):
			keymaps[action] = temp_keymap[action]
			# 设置 keymaps 字典的同时，也更新 InputMap 中的事件。
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keymaps[action])


## 保存按键映射到文件。
## 将整个 keymaps 字典作为变量存储到文件中。
func save_keymap() -> void:
	var file := FileAccess.open(keymaps_path, FileAccess.WRITE)
	file.store_var(keymaps, true)
	file.close()
