## 游戏统计数据 —— 记录节奏游戏的击打统计信息。
##
## 继承自 [Resource]，支持数据持久化和信号通知。
## 每次属性变更时发射 [code]changed[/code] 信号，便于 UI 自动更新。
class_name PlayStats
extends Resource

## 平均击打误差（秒）。负值表示偏早，正值表示偏晚。
@export var mean_hit_error: float = 0.0:
	set(value):
		if mean_hit_error != value:
			mean_hit_error = value
			emit_changed()

## Perfect 判定次数。
@export var perfect_count: int = 0:
	set(value):
		if perfect_count != value:
			perfect_count = value
			emit_changed()

## Good 判定次数。
@export var good_count: int = 0:
	set(value):
		if good_count != value:
			good_count = value
			emit_changed()

## Miss 判定次数。
@export var miss_count: int = 0:
	set(value):
		if miss_count != value:
			miss_count = value
			emit_changed()
