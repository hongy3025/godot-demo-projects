## 玩家控制器 —— 物理驱动的角色主体。
## 继承自 CharacterBody2D，拥有独立的状态机。
## 角色体和状态机是分离的，状态机控制角色的行为逻辑。
extends CharacterBody2D

## 朝向变化信号，传递新的方向向量。
signal direction_changed(new_direction: Vector2)

## 当前朝向方向，变化时自动发射信号。
var look_direction := Vector2.RIGHT:
	set(value):
		look_direction = value
		set_look_direction(value)


## 受到伤害时的回调。
## 参数 attacker: 攻击者节点。
## 参数 amount: 伤害值。
## 参数 effect: 效果节点（可选）。
func take_damage(attacker: Node, amount: float, effect: Node = null) -> void:
	if is_ancestor_of(attacker):
		return

	# 设置击退方向
	$States/Stagger.knockback_direction = (attacker.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)


## 设置死亡状态：禁用输入和物理处理，禁用碰撞多边形。
func set_dead(value: bool) -> void:
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = value


## 设置朝向并发射信号。
func set_look_direction(value: Vector2) -> void:
	direction_changed.emit(value)
