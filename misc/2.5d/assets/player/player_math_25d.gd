## 玩家 3D 物理逻辑 —— 处理移动、跳跃和重力。
##
## 继承自 [CharacterBody3D]，作为 Node25D 的子节点存在。
## 通过 Node25D 的投影系统将 3D 物理位置映射到 2D 精灵渲染。
## 支持普通模式和等距模式两种操控方式。
class_name PlayerMath25D
extends CharacterBody3D


## 垂直方向速度（向上为正），用于跳跃和重力计算。
var vertical_speed: float = 0.0
## 是否启用等距控制模式。启用后 WASD 映射到等距对角方向。
var isometric_controls: bool = true

## 父节点 Node25D 的引用
@onready var _parent_node25d: Node25D = get_parent()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"exit"):
		get_tree().quit()

	if Input.is_action_just_pressed(&"view_cube_demo"):
		get_tree().change_scene_to_file("res://assets/cube/cube.tscn")
		return

	if Input.is_action_just_pressed(&"toggle_isometric_controls"):
		isometric_controls = not isometric_controls
	if Input.is_action_just_pressed(&"reset_position") or position.y <= -100:
		# 重置玩家位置（掉落虚空时自动重置）
		transform = Transform3D(Basis(), Vector3.UP * 0.5)
		vertical_speed = 0
	else:
		_horizontal_movement(delta)
		_vertical_movement(delta)


## 处理水平移动（WASD + Shift）。
## 在等距视角下，将 WASD 映射到对角方向，使操作符合视觉直觉。
func _horizontal_movement(_delta: float) -> void:
	var local_x := Vector3.RIGHT
	var local_z := Vector3.BACK

	# 等距控制模式: 当视角为等距投影时，将 WASD 映射到 45 度对角方向
	if isometric_controls and is_equal_approx(Node25D.SCALE * 0.86602540378, _parent_node25d.get_basis()[0].x):
		local_x = Vector3(0.70710678118, 0, -0.70710678118)
		local_z = Vector3(0.70710678118, 0, 0.70710678118)

	# 获取 WASD 输入并合成 3D 移动方向
	var movement_vec2 := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var move_dir: Vector3 = local_x * movement_vec2.x + local_z * movement_vec2.y

	velocity = move_dir * 10
	if Input.is_action_pressed(&"movement_modifier"):
		velocity /= 2

	move_and_slide()


## 处理垂直移动（跳跃 + 重力）。
## 使用 move_and_collide 检测落地，落地后重置垂直速度。
func _vertical_movement(delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"):
		vertical_speed = 60

	vertical_speed -= delta * 240  # 重力加速度
	var k := move_and_collide(Vector3.UP * vertical_speed * delta)

	if k != null:
		vertical_speed = 0
