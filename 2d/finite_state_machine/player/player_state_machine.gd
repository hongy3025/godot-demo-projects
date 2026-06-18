## 玩家状态机 —— 管理玩家所有状态的切换和堆叠。
## 继承自通用状态机，扩展了状态栈管理（支持中断状态压栈）。
extends "res://state_machine/state_machine.gd"

## 预加载玩家状态常量字典。
var PLAYER_STATE = preload("res://player/player_state.gd").PLAYER_STATE

## 各状态节点的引用。
@onready var idle: Node = $Idle
@onready var move: Node = $Move
@onready var jump: Node = $Jump
@onready var stagger: Node = $Stagger
@onready var attack: Node = $Attack

func _ready() -> void:
	states_map = {
		PLAYER_STATE.idle: idle,
		PLAYER_STATE.move: move,
		PLAYER_STATE.jump: jump,
		PLAYER_STATE.stagger: stagger,
		PLAYER_STATE.attack: attack,
	}


## 重写状态切换逻辑：支持中断状态（踉跄、跳跃、攻击）压入状态栈，
## 以便结束后能回到之前的状态。
func _change_state(state_name: String) -> void:
	if not _active:
		return
	# 中断状态压入栈顶，结束后可回到上一个状态
	if state_name in [PLAYER_STATE.stagger, PLAYER_STATE.jump, PLAYER_STATE.attack]:
		states_stack.push_front(states_map[state_name])
	# 从移动状态跳跃时传递当前速度参数
	if state_name == PLAYER_STATE.jump and current_state == move:
		jump.initialize(move.speed, move.velocity)

	super._change_state(state_name)


## 处理可中断状态的输入：攻击输入可中断大多数状态。
func _unhandled_input(input_event: InputEvent) -> void:
	# 攻击输入可中断当前状态（但不能在攻击或踉跄中再次攻击）
	if input_event.is_action_pressed(PLAYER_STATE.attack):
		if current_state in [attack, stagger]:
			return

		_change_state(PLAYER_STATE.attack)
		return

	current_state.handle_input(input_event)
