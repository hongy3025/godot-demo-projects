## 对话播放器 —— 从 JSON 文件加载并逐句播放对话。
## 继承自 Node，通过信号通知对话开始和结束。
extends Node

## 对话开始信号。
signal dialogue_started
## 对话结束信号。
signal dialogue_finished

## 对话 JSON 文件路径（通过 @export_file 限制为 .json 文件）。
@export_file("*.json") var dialogue_file: String
## 对话键值列表，存储从 JSON 解析出的所有对话条目。
var dialogue_keys := []
## 当前说话者的名称。
var dialogue_name: String = ""
## 当前对话索引。
var current := 0
## 当前显示的对话文本。
var dialogue_text: String = ""


## 开始播放对话：发射开始信号，加载第一条对话。
func start_dialogue() -> void:
	dialogue_started.emit()
	current = 0
	index_dialogue()
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


## 切换到下一条对话。如果已到最后一条，发射结束信号。
func next_dialogue() -> void:
	current += 1
	if current == dialogue_keys.size():
		dialogue_finished.emit()
		return
	dialogue_text = dialogue_keys[current].text
	dialogue_name = dialogue_keys[current].name


## 索引对话文件：将 JSON 中的键值对转换为有序列表。
func index_dialogue() -> void:
	var dialogue: Dictionary = load_dialogue(dialogue_file)
	dialogue_keys.clear()
	for key: String in dialogue:
		dialogue_keys.append(dialogue[key])


## 从文件加载 JSON 对话数据。
## 参数 file_path: JSON 文件路径。
## 返回: 解析后的 Dictionary。
func load_dialogue(file_path: String) -> Dictionary:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file:
		var test_json_conv := JSON.new()
		test_json_conv.parse(file.get_as_text())
		return test_json_conv.data

	return {}
