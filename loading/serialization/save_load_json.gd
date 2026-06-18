## JSON 格式存档示例 —— 演示使用 JSON 文件格式保存和加载游戏数据。
## 继承自 [Button]，作为存档/读档按钮。
## JSON 是广泛使用的文件格式，但并非所有 Godot 类型都能原生存储。
## 例如：整数会被转换为浮点数，Vector2 等非 JSON 类型需要使用 var_to_str 转换为字符串。
extends Button
# 此脚本演示如何使用 JSON 文件格式保存数据。
# JSON 是广泛使用的文件格式，但并非所有 Godot 类型都能原生存储。
# 例如：整数会被转换为浮点数，Vector2 等非 JSON 类型需要使用 var_to_str 转换为字符串。

## 游戏根节点的 NodePath，用于获取和实例化敌人。
@export var game_node: NodePath
## 玩家节点的 NodePath，用于获取/设置玩家的生命值和位置。
@export var player_node: NodePath

## 存档文件保存路径（user:// 表示 Godot 的用户数据目录）。
const SAVE_PATH = "user://save_json.json"


## 保存游戏数据到 JSON 文件。
## 核心逻辑: 将玩家属性（位置、生命值、旋转角度）和所有敌人的位置序列化为字典，
## 使用 var_to_str 将 Vector2 等非 JSON 原生类型转换为字符串，最后用 JSON.stringify 写入文件。
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	var player := get_node(player_node)
	# JSON 不支持许多 Godot 类型（如 Vector2）。
	# var_to_str 可以将任何 Variant 转换为字符串。
	var save_dict := {
		player = {
			position = var_to_str(player.position),
			health = var_to_str(player.health),
			rotation = var_to_str(player.sprite.rotation),
		},
		enemies = [],
	}

	# 遍历所有在 "enemy" 组中的节点，保存它们的位置
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		save_dict.enemies.push_back({
			position = var_to_str(enemy.position),
		})

	file.store_line(JSON.stringify(save_dict))

	# 启用"加载 JSON"按钮
	get_node(^"../LoadJSON").disabled = false


## 从 JSON 文件加载游戏数据。
## 核心逻辑: 读取 JSON 文件，解析后使用 str_to_var 将字符串还原为 Godot 原生类型，
## 恢复玩家属性，清除现有敌人并重新实例化。
func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict := json.get_data() as Dictionary

	var player := get_node(player_node) as Player
	# JSON 不支持许多 Godot 类型（如 Vector2）。
	# str_to_var 可以将字符串转换回对应的 Variant。
	player.position = str_to_var(save_dict.player.position)
	player.health = str_to_var(save_dict.player.health)
	player.sprite.rotation = str_to_var(save_dict.player.rotation)

	# 在添加新敌人之前移除现有敌人
	get_tree().call_group(&"enemy", &"queue_free")

	# 确保加载时的节点结构与保存时一致
	var game := get_node(game_node)

	# 遍历存档中的敌人配置，重新实例化敌人
	for enemy_config: Dictionary in save_dict.enemies:
		var enemy: Enemy = preload("res://enemy.tscn").instantiate()
		enemy.position = str_to_var(enemy_config.position)
		game.add_child(enemy)
