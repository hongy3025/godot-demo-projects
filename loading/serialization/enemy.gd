## 敌人角色 —— 演示序列化/反序列化的目标对象。
## 继承自 [Node2D]，作为场景中的移动敌人。
## 拥有攻击系统：当玩家进入攻击范围时，每帧对玩家造成持续伤害。
## 自动向右移动，超出屏幕后从左端重新出现。
class_name Enemy
extends Node2D

## 移动速度，单位：像素/秒。
const MOVEMENT_SPEED = 75.0
## 每秒对玩家造成的伤害值。
const DAMAGE_PER_SECOND = 15.0

## 当前正在攻击的玩家引用。
## 如果为 [code]null[/code]，表示范围内没有玩家。
var attacking: Player = null


## 每帧处理攻击和移动逻辑。
## 参数:
##   delta: 上一帧到这一帧的时间差（秒）
## 核心逻辑: 如果正在攻击玩家，按时间比例扣除生命值。然后向右移动，
## 超出屏幕右边界（x >= 732）时从左边界（x = -32）重新出现。
func _process(delta: float) -> void:
	# 如果 attacking 引用有效，对玩家造成持续伤害
	if is_instance_valid(attacking):
		attacking.health -= delta * DAMAGE_PER_SECOND

	position.x += MOVEMENT_SPEED * delta

	# 敌人移出窗口后，将其移回左侧
	if position.x >= 732:
		position.x = -32


## 攻击区域进入信号回调 —— 当 PhysicsBody2D 进入敌人的攻击范围时触发。
## 参数:
##   body: 进入攻击区域的物理体
## 核心逻辑: 如果进入的是 Player 类型，则将其设置为攻击目标。
func _on_attack_area_body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		attacking = body


## 攻击区域退出信号回调 —— 当 PhysicsBody2D 离开敌人的攻击范围时触发。
## 参数:
##   _body: 离开攻击区域的物理体（此处未使用）
## 核心逻辑: 将攻击目标置为 null，停止攻击。
func _on_attack_area_body_exited(_body: PhysicsBody2D) -> void:
	attacking = null
