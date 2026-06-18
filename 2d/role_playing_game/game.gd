## RPG 游戏主控制器 —— 管理探索和战斗场景的切换。
## 继承自 Node，负责场景过渡动画、战斗初始化和结果处理。
extends Node

## 玩家胜利时的对话文件路径。
const PLAYER_WIN = "res://dialogue/dialogue_data/player_won.json"
## 玩家失败时的对话文件路径。
const PLAYER_LOSE = "res://dialogue/dialogue_data/player_lose.json"

## 战斗场景节点。
@export var combat_screen: Node2D
## 探索场景节点。
@export var exploration_screen: Node2D


## 初始化：连接战斗结束信号和所有对手的对话结束信号。
func _ready() -> void:
	combat_screen.combat_finished.connect(_on_combat_finished)

	# 遍历所有对手棋子，连接对话结束信号
	for n in $Exploration/Grid.get_children():
		if not n.type == n.CellType.ACTOR:
			continue
		if not n.has_node(^"DialoguePlayer"):
			continue
		n.get_node(^"DialoguePlayer").dialogue_finished.connect(_on_opponent_dialogue_finished.bind(n))

	# 将战斗场景从场景树中移除（暂不显示）
	remove_child(combat_screen)


## 开始战斗：播放淡入黑屏动画，切换到战斗场景。
## 参数 combat_actors: 参战角色的 PackedScene 数组。
func start_combat(combat_actors: Array[PackedScene]) -> void:
	$AnimationPlayer.play(&"fade_to_black")
	await $AnimationPlayer.animation_finished
	remove_child($Exploration)
	add_child(combat_screen)
	combat_screen.show()
	combat_screen.initialize(combat_actors)
	$AnimationPlayer.play_backwards(&"fade_to_black")


## 对手对话结束后的回调 —— 触发战斗。
## 参数 opponent: 对话结束的对手棋子。
func _on_opponent_dialogue_finished(opponent: Pawn) -> void:
	if opponent.lost:
		return
	var player: Node2D = $Exploration/Grid/Player
	var combatants: Array[PackedScene] = [player.combat_actor, opponent.combat_actor]
	start_combat(combatants)


## 战斗结束后的回调 —— 根据胜负播放对应对话，返回探索场景。
## 参数 winner: 胜利的战斗者。
## 参数 _loser: 失败的战斗者。
func _on_combat_finished(winner: Combatant, _loser: Combatant) -> void:
	remove_child(combat_screen)
	$AnimationPlayer.play_backwards(&"fade_to_black")
	add_child(exploration_screen)
	var dialogue: Node = load("res://dialogue/dialogue_player/dialogue_player.tscn").instantiate()

	# 根据胜负加载不同的对话文件
	if winner.name == "Player":
		dialogue.dialogue_file = PLAYER_WIN
	else:
		dialogue.dialogue_file = PLAYER_LOSE

	await $AnimationPlayer.animation_finished
	var player: Pawn = $Exploration/Grid/Player
	exploration_screen.get_node(^"DialogueCanvas/DialogueUI").show_dialogue(player, dialogue)
	combat_screen.clear_combat()
	await dialogue.dialogue_finished
	dialogue.queue_free()
