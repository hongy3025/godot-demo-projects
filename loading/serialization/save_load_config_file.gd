## ConfigFile 格式存档示例 —— 演示使用 Godot 自定义的 ConfigFile 格式保存和加载游戏数据。
## 继承自 [Button]，作为存档/读档按钮。
## ConfigFile 可以存储除 Signal 和 Callable 之外的任何 Variant 类型，
## 甚至可以存储 Object，但反序列化时需格外小心，因为可能包含（潜在恶意的）脚本。
extends Button
# 此脚本演示如何使用 Godot 自定义的 ConfigFile 格式保存数据。
# ConfigFile 可以存储除 Signal 和 Callable 之外的任何 Variant 类型。
# 甚至可以存储 Object，但反序列化时需格外小心，因为可能包含（潜在恶意的）脚本。

## 存档文件保存路径（user:// 表示 Godot 的用户数据目录）。
const SAVE_PATH = "user://save_config_file.ini"

## 游戏根节点的 NodePath，用于获取和实例化敌人。
@export var game_node: NodePath
## 玩家节点的 NodePath，用于获取/设置玩家的生命值和位置。
@export var player_node: NodePath


## 保存游戏数据到 ConfigFile 文件。
## 核心逻辑: 使用 ConfigFile.set_value() 按节（section）存储玩家属性和敌人列表，
## 最后调用 save() 写入文件。ConfigFile 原生支持 Vector2 等 Godot 类型，无需转换。
func save_game() -> void:
	var config := ConfigFile.new()

	var player := get_node(player_node) as Player
	config.set_value("player", "position", player.position)
	config.set_value("player", "health", player.health)
	config.set_value("player", "rotation", player.sprite.rotation)

	# 遍历所有在 "enemy" 组中的节点，保存它们的位置
	var enemies := []
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		enemies.push_back({
			position = enemy.position,
		})
	config.set_value("enemies", "enemies", enemies)

	config.save(SAVE_PATH)

	# 启用"加载 ConfigFile"按钮
	($"../LoadConfigFile" as Button).disabled = false


## 从 ConfigFile 文件加载游戏数据。
## 核心逻辑: 使用 ConfigFile.get_value() 按节读取数据，恢复玩家属性，
## 清除现有敌人并根据存档数据重新实例化。
func load_game() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	var player := get_node(player_node) as Player
	player.position = config.get_value("player", "position")
	player.health = config.get_value("player", "health")
	player.sprite.rotation = config.get_value("player", "rotation")

	# 在添加新敌人之前移除现有敌人
	get_tree().call_group(&"enemy", &"queue_free")

	var enemies: Array = config.get_value("enemies", "enemies")
	var game := get_node(game_node)

	# 遍历存档中的敌人配置，重新实例化敌人
	for enemy_config: Dictionary in enemies:
		var enemy := preload("res://enemy.tscn").instantiate() as Enemy
		enemy.position = enemy_config.position
		game.add_child(enemy)
