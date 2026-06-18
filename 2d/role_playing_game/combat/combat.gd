## 战斗场景主控制器 —— 管理战斗的初始化和结束。
## 继承自 Node，负责实例化战斗者、初始化回合队列和处理战斗结果。
extends Node

## 战斗结束信号，传递胜者和败者。
signal combat_finished(winner: Combatant, loser: Combatant)

## UI 节点引用。
@onready var ui := $CombatCanvas/UI


func _ready() -> void:
	ui.flee.connect(_on_flee)


## 逃跑回调：直接结束战斗。
func _on_flee(winner: Combatant, loser: Combatant) -> void:
	finish_combat(winner, loser)


## 初始化战斗：实例化所有参战者，连接死亡信号，初始化 UI 和回合队列。
## 参数 combat_combatants: 参战角色的 PackedScene 数组。
func initialize(combat_combatants: Array[PackedScene]) -> void:
	for combatant_scene in combat_combatants:
		var combatant := combatant_scene.instantiate()
		if combatant is Combatant:
			$Combatants.add_combatant(combatant)
			combatant.get_node(^"Health").dead.connect(_on_combatant_death.bind(combatant))
		else:
			combatant.queue_free()
	ui.initialize()
	$TurnQueue.initialize()


## 清理战斗场景：移除所有战斗者和血量条。
func clear_combat() -> void:
	for n in $Combatants.get_children():
		n.queue_free()
	for n in ui.get_node(^"Combatants").get_children():
		n.queue_free()


## 结束战斗并发射信号。
## 参数 winner: 胜利者。
## 参数 loser: 失败者。
func finish_combat(winner: Combatant, loser: Combatant) -> void:
	combat_finished.emit(winner, loser)


## 战斗者死亡回调：确定胜者并结束战斗。
## 参数 combatant: 死亡的角色。
func _on_combatant_death(combatant: Combatant) -> void:
	var winner: Combatant
	if not combatant.name == "Player":
		winner = $Combatants/Player
	else:
		for n in $Combatants.get_children():
			if not n.name == "Player":
				winner = n
				break

	finish_combat(winner, combatant)
