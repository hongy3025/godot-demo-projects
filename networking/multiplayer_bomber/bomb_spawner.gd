## 炸弹生成器 —— 通过 MultiplayerSpawner 在网络上同步生成炸弹。
##
## 继承自 [MultiplayerSpawner]，利用 Godot 内置的多人游戏生成器
## 在所有对等端上自动同步生成炸弹实例。
extends MultiplayerSpawner


## 构造函数：设置自定义生成函数。
func _init() -> void:
	spawn_function = _spawn_bomb


## 自定义炸弹生成函数。
## 参数 data: 包含 [位置, 玩家ID] 的数组。
## 返回: 生成的炸弹 Area2D 实例，数据格式错误时返回 null。
func _spawn_bomb(data: Array) -> Area2D:
	if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR2 or typeof(data[1]) != TYPE_INT:
		return null

	var bomb: Area2D = preload("res://bomb.tscn").instantiate()
	bomb.position = data[0]
	bomb.from_player = data[1]
	return bomb
