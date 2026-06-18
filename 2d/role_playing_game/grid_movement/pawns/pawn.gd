## 网格棋子基类 —— 所有网格上可放置对象的基础类型。
## 继承自 Node2D，包含格子类型定义和激活状态控制。
class_name Pawn
extends Node2D

## 格子类型枚举。
enum CellType {
	ACTOR,    # 角色（可移动）
	OBSTACLE, # 障碍物（不可通行）
	OBJECT,   # 物体（可交互）
}

## 当前棋子的格子类型。
@export var type := CellType.ACTOR

## 是否处于激活状态。设为 false 时停止处理输入和帧更新。
var active: bool = true: set = set_active

## 设置激活状态，同时控制 _process 和 _input 的启用。
func set_active(value: bool) -> void:
	active = value
	set_process(value)
	set_process_input(value)
