## 有限状态机 —— 通用状态机接口基类。
## 继承自 Node，管理状态初始化、激活、委托 _physics_process/_input 给当前状态节点，
## 以及切换当前/活跃状态。
## 参考 PlayerV2 场景了解使用示例。
extends Node

## 状态变化信号，传递当前状态节点。
signal state_changed(current_state: Node)

## 起始状态节点路径。应在编辑器或继承节点中设置。
## 如果未设置，默认使用状态机的第一个子节点。
@export var start_state: NodePath
## 状态名称到状态节点的映射字典。
var states_map := {}

## 状态栈，支持状态回退（回到上一个状态）。
var states_stack := []
## 当前活跃状态节点。
var current_state: Node = null
## 是否激活状态机。
var _active: bool = false:
	set(value):
		_active = value
		set_active(value)


## 进入场景树时初始化：确定起始状态，连接所有子状态的 finished 信号。
func _enter_tree() -> void:
	var initial_state: Node
	if start_state.is_empty():
		# 子节点在父节点的 _enter_tree() 期间尚未进入场景树，
		# 因此调用 get_child(0).get_path() 会返回空 NodePath。
		# 直接使用节点引用。
		initial_state = get_child(0)
	else:
		initial_state = get_node(start_state)
	# 连接所有子状态的 finished 信号到 _change_state
	for child in get_children():
		var err: bool = child.finished.connect(_change_state)
		if err:
			printerr(err)
	initialize(initial_state)


## 初始化状态机：激活并进入起始状态。
## 参数 initial_state: 起始状态节点。
func initialize(initial_state: Node) -> void:
	_active = true
	states_stack.push_front(initial_state)
	current_state = states_stack[0]
	current_state.enter()


## 设置状态机激活状态：控制 _physics_process 和 _input 的启用。
func set_active(value: bool) -> void:
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null


## 委托输入事件给当前状态处理。
func _unhandled_input(input_event: InputEvent) -> void:
	current_state.handle_input(input_event)


## 委托物理帧更新给当前状态处理。
func _physics_process(delta: float) -> void:
	current_state.update(delta)


## 动画播放完成回调，委托给当前状态处理。
func _on_animation_finished(anim_name: String) -> void:
	if not _active:
		return

	current_state._on_animation_finished(anim_name)


## 切换状态。支持 "previous" 回退到上一个状态。
## 参数 state_name: 目标状态名称。
func _change_state(state_name: String) -> void:
	if not _active:
		return
	current_state.exit()

	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]

	current_state = states_stack[0]
	state_changed.emit(current_state)

	if state_name != "previous":
		current_state.enter()
