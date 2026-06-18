## 玩家控制器 —— 鼠标跟随 + 碰撞反馈。
##
## 玩家角色跟随鼠标光标移动，被子弹击中时切换表情。
## 碰撞检测通过 PhysicsServer2D 的 body_shape_entered/exited 信号驱动。
extends Node2D

## 当前与玩家发生碰撞的子弹数量。
## 当 touching > 0 时显示悲伤表情，= 0 时恢复开心表情。
var touching: int = 0

## 玩家动画精灵的引用。
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


## _ready 入口：隐藏鼠标光标，因为玩家位置由鼠标控制。
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


## 处理鼠标移动输入，将玩家位置同步到鼠标位置。
## 偏移 Vector2(0, 16) 使精灵中心对准鼠标指针。
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		position = input_event.position - Vector2(0, 16)


## 碰撞体进入回调 —— 子弹碰到玩家时触发。
## 增加 touching 计数，当 touching >= 1 时切换为悲伤表情（第 1 帧）。
func _on_body_shape_entered(_body_id: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	touching += 1
	if touching >= 1:
		sprite.frame = 1


## 碰撞体退出回调 —— 子弹离开玩家时触发。
## 减少 touching 计数，当 touching == 0 时恢复开心表情（第 0 帧）。
func _on_body_shape_exited(_body_id: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	touching -= 1
	if touching == 0:
		sprite.frame = 0
