## 战斗 UI 控制器 —— 显示战斗者信息和操作按钮。
## 继承自 Control，提供攻击、防御、逃跑按钮并更新血量显示。
extends Control

## 逃跑信号，通知战斗结果。
signal flee(winner: Combatant, loser: Combatant)

## 战斗者列表的父节点。
@export var combatants_node: Node
## 血量信息显示场景的 PackedScene。
@export var info_scene: PackedScene


## 初始化 UI：为每个战斗者创建血量信息条，连接血量变化信号。
func initialize() -> void:
	for combatant in combatants_node.get_children():
		var health := combatant.get_node(^"Health")
		var info := info_scene.instantiate()
		var health_info := info.get_node(^"VBoxContainer/HealthContainer/Health")
		health_info.value = health.life
		health_info.max_value = health.max_life
		info.get_node(^"VBoxContainer/NameContainer/Name").text = combatant.name
		# 连接血量变化信号，自动更新 UI
		health.health_changed.connect(health_info.set_value)
		$Combatants.add_child(info)

	# 默认聚焦攻击按钮
	$Buttons/GridContainer/Attack.grab_focus()


## 攻击按钮回调：玩家攻击对手。
func _on_Attack_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return

	combatants_node.get_node(^"Player").attack(combatants_node.get_node(^"Opponent"))


## 防御按钮回调：玩家进入防御状态。
func _on_Defend_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return

	combatants_node.get_node(^"Player").defend()


## 逃跑按钮回调：玩家逃跑，发射逃跑信号。
func _on_Flee_button_up() -> void:
	if not combatants_node.get_node(^"Player").active:
		return

	combatants_node.get_node(^"Player").flee()

	var loser: Combatant = combatants_node.get_node(^"Player")
	var winner: Combatant = combatants_node.get_node(^"Opponent")
	flee.emit(winner, loser)
