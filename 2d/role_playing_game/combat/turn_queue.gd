## 战斗回合队列 —— 管理战斗者的行动顺序。
## 继承自 Node，使用循环队列实现回合制战斗的轮转。
extends Node

## 当前活跃战斗者变化时发射的信号。
signal active_combatant_changed(active_combatant: Combatant)

## 战斗者列表的父节点。
@export var combatants_list: Node

## 回合队列（循环队列）。
var queue: Array[Node] = []: set = set_queue
## 当前活跃（可行动）的战斗者。
var active_combatant: Combatant = null: set = _set_active_combatant

## 初始化队列并开始第一个回合。
func initialize() -> void:
	set_queue(combatants_list.get_children())
	play_turn()


## 循环执行回合：等待当前战斗者完成行动后切换到下一个。
func play_turn() -> void:
	await active_combatant.turn_finished
	get_next_in_queue()
	play_turn()


## 获取队列中的下一个战斗者（循环队列）。
## 将当前战斗者移到队尾，队首成为新的活跃战斗者。
## 返回: 新的活跃战斗者。
func get_next_in_queue() -> Node:
	var current_combatant: Node = queue.pop_front()
	current_combatant.active = false
	queue.append(current_combatant)
	active_combatant = queue[0]
	return active_combatant


## 从队列中移除一个战斗者（通常因死亡）。
## 参数 combatant: 要移除的战斗者。
func remove(combatant: Combatant) -> void:
	var new_queue := []
	for n in queue:
		new_queue.append(n)
	new_queue.remove_at(new_queue.find(combatant))
	combatant.queue_free()
	queue = new_queue


## 设置队列：过滤出 Combatant 类型的子节点，初始化第一个为活跃战斗者。
func set_queue(new_queue: Array[Node]) -> void:
	queue.clear()
	for node in new_queue:
		if node is not Combatant:
			continue
		queue.append(node)
		node.active = false
	if queue.size() > 0:
		active_combatant = queue[0]


## 设置当前活跃战斗者：激活该战斗者并发射信号。
func _set_active_combatant(new_combatant: Combatant) -> void:
	active_combatant = new_combatant
	active_combatant.active = true
	active_combatant_changed.emit(active_combatant)
