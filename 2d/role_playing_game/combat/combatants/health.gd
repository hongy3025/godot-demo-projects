## 生命值系统 —— 管理战斗者的血量、护甲和伤害计算。
## 继承自 Node，通过信号通知血量变化和死亡事件。
extends Node

## 死亡信号。
signal dead
## 血量变化信号，参数为当前血量。
signal health_changed(life: float)

## 当前生命值。
@export var life := 0
## 最大生命值。
@export var max_life := 10
## 基础护甲值。
@export var base_armor := 0

## 当前护甲值（含防御加成）。
var armor := 0

func _ready() -> void:
	armor = base_armor


## 受到伤害：计算最终伤害（伤害 - 护甲），生命值归零时发射死亡信号。
## 参数 damage: 原始伤害值。
func take_damage(damage: int) -> void:
	life = life - damage + armor
	if life <= 0:
		dead.emit()
	else:
		health_changed.emit(life)


## 治疗：恢复生命值，不超过最大生命值。
## 参数 amount: 治疗量。
func heal(amount: int) -> void:
	life += amount
	life = clamp(life, life, max_life)
	health_changed.emit(life)


## 获取当前生命值比例。
## 返回: 0.0 ~ 1.0 之间的浮点数。
func get_health_ratio() -> float:
	return float(life) / max_life
