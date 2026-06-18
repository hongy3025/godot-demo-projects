## 导航角色节点 —— 通过 NavigationAgent2D 实现自动寻路移动。
## 继承自 CharacterBody2D，使用 Godot 导航系统自动计算路径并跟随。
extends CharacterBody2D


## 角色移动速度（像素/秒）。
var movement_speed := 200.0

## 导航代理节点，负责路径计算和寻路逻辑。
## @onready 确保在 _ready 之前完成节点引用。
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


## 初始化导航代理参数。
## 设置路径终点距离和路径点距离的容差，开启调试显示。
func _ready() -> void:
	# 路径点距离容差：角色距离路径点多少时认为到达该点
	navigation_agent.path_desired_distance = 2.0
	# 目标点距离容差：角色距离最终目标多少时认为到达
	navigation_agent.target_desired_distance = 2.0
	# 开启调试显示，在编辑器中可视化导航路径
	navigation_agent.debug_enabled = true


## 处理鼠标点击输入事件。
## "click" 是自定义输入动作，在 项目设置 > 输入映射 中定义。
func _unhandled_input(input_event: InputEvent) -> void:
	if not input_event.is_action_pressed(&"click"):
		return
	# 点击时设置鼠标位置为导航目标
	set_movement_target(get_global_mouse_position())


## 设置导航移动目标位置。
## 参数 movement_target: 目标点的全局坐标。
func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.target_position = movement_target


## 物理帧更新 —— 每帧根据导航路径计算移动速度并驱动角色。
func _physics_process(_delta: float) -> void:
	# 如果导航已完成（到达目标），停止移动
	if navigation_agent.is_navigation_finished():
		return

	# 获取当前角色位置和下一个路径点的位置
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	# 计算朝向路径点的速度方向，乘以移动速度
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	# 应用速度并处理碰撞
	move_and_slide()
