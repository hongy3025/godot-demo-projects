## 剑武器节点 —— 实现连击系统的攻击判定区域。
## 继承自 Area2D，支持最多 3 连击，通过 AnimationPlayer 驱动攻击动画。
extends Area2D

## 攻击完成信号。
signal attack_finished

## 武器状态枚举。
enum States {
	IDLE,    # 待机
	ATTACK,  # 攻击中
}

## 攻击输入状态枚举，用于连击输入窗口管理。
enum AttackInputStates {
	IDLE,       # 空闲
	LISTENING,  # 监听输入（可输入下一击）
	REGISTERED, # 已注册输入（等待当前动画结束）
}

## 当前武器状态。
var state: States = States.IDLE
## 当前攻击输入状态。
var attack_input_state := AttackInputStates.IDLE
## 是否准备好进行下一次攻击（由动画关键帧触发）。
var ready_for_next_attack: bool = false
## 最大连击次数。
const MAX_COMBO_COUNT = 3
## 当前连击计数。
var combo_count := 0

## 当前攻击数据。
var attack_current := {}
## 连击数据配置：每击的伤害、动画名称和效果。
var combo := [{
		"damage": 1,
		"animation": "attack_fast",
		"effect": null,
	},
	{
		"damage": 1,
		"animation": "attack_fast",
		"effect": null,
	},
	{
		"damage": 3,
		"animation": "attack_medium",
		"effect": null,
	}
]

## 已击中的对象列表，防止一次攻击多次伤害同一目标。
var hit_objects := []


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	_change_state(States.IDLE)


## 切换武器状态。
## 参数 new_state: 目标状态。
func _change_state(new_state: States) -> void:
	match state:
		States.ATTACK:
			# 退出攻击状态时重置
			hit_objects = []
			attack_input_state = AttackInputStates.LISTENING
			ready_for_next_attack = false

	match new_state:
		States.IDLE:
			combo_count = 0
			$AnimationPlayer.stop()
			visible = false
			monitoring = false
		States.ATTACK:
			attack_current = combo[combo_count -1]
			$AnimationPlayer.play(attack_current["animation"])
			visible = true
			monitoring = true

	state = new_state


## 在攻击状态下监听攻击输入，注册连击。
func _unhandled_input(input_event: InputEvent) -> void:
	if not state == States.ATTACK:
		return
	if attack_input_state != AttackInputStates.LISTENING:
		return
	if input_event.is_action_pressed(&"attack"):
		attack_input_state = AttackInputStates.REGISTERED


## 物理帧更新：如果已注册连击输入且准备好，执行下一次攻击。
func _physics_process(_delta: float) -> void:
	if attack_input_state == AttackInputStates.REGISTERED and ready_for_next_attack:
		attack()


## 执行攻击：增加连击计数并切换状态。
func attack() -> void:
	combo_count += 1
	_change_state(States.ATTACK)


## 由 AnimationPlayer 的函数轨迹调用：开始监听攻击输入。
func set_attack_input_listening() -> void:
	attack_input_state = AttackInputStates.LISTENING


## 由 AnimationPlayer 的函数轨迹调用：标记为准备好下一次攻击。
func set_ready_for_next_attack() -> void:
	ready_for_next_attack = true


## 碰撞体进入回调：对目标造成伤害（防止重复伤害同一目标）。
func _on_body_entered(body: Node2D) -> void:
	if not body.has_node(^"Health"):
		return
	if body.get_rid().get_id() in hit_objects:
		return

	hit_objects.append(body.get_rid().get_id())
	body.take_damage(self, attack_current["damage"], attack_current["effect"])


## 动画播放完成回调：根据连击输入状态决定继续连击或回到待机。
func _on_animation_finished(_name: String) -> void:
	if attack_current.is_empty():
		return

	if attack_input_state == AttackInputStates.REGISTERED and combo_count < MAX_COMBO_COUNT:
		attack()
	else:
		_change_state(States.IDLE)
		attack_finished.emit()


## 状态机状态变化回调：当切换到攻击状态时自动执行攻击。
func _on_StateMachine_state_changed(current_state: Node) -> void:
	if current_state.name == "Attack":
		attack()
