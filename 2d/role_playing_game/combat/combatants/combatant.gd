## 战斗者基类 —— 所有战斗实体的基础。
## 继承自 Node，提供攻击、防御、逃跑等基本战斗行为。
class_name Combatant
extends Node

## 回合结束信号，通知回合队列当前战斗者已完成行动。
signal turn_finished

## 攻击力。
@export var damage := 1
## 防御力（防御时增加护甲）。
@export var defense := 1

## 是否处于可行动状态。
var active: bool = false: set = set_active

## 动画状态机播放控制器。
@onready var animation_playback: AnimationNodeStateMachinePlayback = $Sprite2D/AnimationTree.get(&"parameters/playback")

## 设置激活状态：控制 _process 和 _input 的启用，并在激活时重置护甲。
func set_active(value: bool) -> void:
	active = value
	set_process(value)
	set_process_input(value)

	if not active:
		return
	# 激活时如果护甲超过基础值+防御加成，重置为基础护甲
	if $Health.armor >= $Health.base_armor + defense:
		$Health.armor = $Health.base_armor


## 攻击目标战斗者。
## 参数 target: 被攻击的战斗者。
func attack(target: Combatant) -> void:
	target.take_damage(damage)
	turn_finished.emit()


## 防御：增加护甲值，本回合受到的伤害减少。
func defend() -> void:
	$Health.armor += defense
	turn_finished.emit()


## 逃跑：直接结束回合。
func flee() -> void:
	turn_finished.emit()


## 受到伤害：委托给 Health 节点处理，并播放受伤动画。
## 参数 damage_to_take: 受到的伤害值。
func take_damage(damage_to_take: float) -> void:
	$Health.take_damage(damage_to_take)
	animation_playback.start(&"take_damage")
