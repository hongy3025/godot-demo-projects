## 物理测试基类 —— 提供物理测试的通用工具方法。
##
## 继承自 [Node]，提供球体绘制、形状绘制、刚体创建、
## 计时器、物理帧等待等测试辅助功能。
class_name Test
extends Node


## 等待完成信号。
signal wait_done()

## 是否启用调试碰撞显示。
@export var _enable_debug_collision: bool = true

## 计时器引用。
var _timer: Timer
## 计时器是否已启动。
var _timer_started: bool = false

## 等待物理帧计数器。
var _wait_physics_ticks_counter: int = 0

## 已绘制的调试节点列表。
var _drawn_nodes: Array[Node3D] = []


func _enter_tree() -> void:
	if not _enable_debug_collision:
		get_tree().debug_collisions_hint = false


func _physics_process(_delta: float) -> void:
	if _wait_physics_ticks_counter > 0:
		_wait_physics_ticks_counter -= 1
		if _wait_physics_ticks_counter == 0:
			wait_done.emit()


## 在场景中添加一个用于调试的球体 MeshInstance3D。
##
## 参数:
##   pos: 球体位置
##   radius: 球体半径
##   color: 球体颜色
func add_sphere(pos: Vector3, radius: float, color: Color) -> void:
	var sphere := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere.mesh = sphere_mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	sphere.set_surface_override_material(0, material)
	_drawn_nodes.push_back(sphere)
	add_child(sphere)
	sphere.global_transform.origin = pos


## 在场景中添加一个用于调试的形状 MeshInstance3D。
##
## 参数:
##   shape: 形状
##   transform: 变换
##   color: 颜色
func add_shape(shape: Shape3D, transform: Transform3D, color: Color) -> void:
	var debug_mesh := shape.get_debug_mesh()
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.transform = transform
	mesh_instance.mesh = debug_mesh
	var material := StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)
	add_child(mesh_instance)
	_drawn_nodes.push_back(mesh_instance)


## 清除所有已绘制的调试节点。
func clear_drawn_nodes() -> void:
	for node in _drawn_nodes:
		remove_child(node)
		node.queue_free()
	_drawn_nodes.clear()


## 创建一个 RigidBody3D。
##
## 参数:
##   shape: 碰撞形状
##   pickable: 是否可拾取
##   transform: 变换
##
## 返回: [RigidBody3D] 创建的刚体
func create_rigidbody(shape: Shape3D, pickable: bool = false, transform: Transform3D = Transform3D.IDENTITY) -> RigidBody3D:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.transform = transform
	collision.debug_color = Color.YELLOW
	var body := RigidBody3D.new()
	body.add_child(collision)
	if pickable:
		var script := load("res://utils/rigidbody_pick.gd")
		body.set_script(script)
	return body


## 创建一个盒子形状的 RigidBody3D。
##
## 参数:
##   size: 盒子尺寸
##   pickable: 是否可拾取
##   transform: 变换
##
## 返回: [RigidBody3D] 创建的刚体盒子
func create_rigidbody_box(size: Vector3, pickable: bool = false, transform: Transform3D = Transform3D.IDENTITY) -> RigidBody3D:
	var shape := BoxShape3D.new()
	shape.size = size
	return create_rigidbody(shape, pickable, transform)


## 启动一个计时器。
##
## 参数:
##   timeout: 超时时间（秒）
##
## 返回: [Timer] 创建的计时器
func start_timer(timeout: float) -> Timer:
	if _timer == null:
		_timer = Timer.new()
		_timer.one_shot = true
		add_child(_timer)
		_timer.timeout.connect(_on_timer_done)
	else:
		cancel_timer()
	_timer.start(timeout)
	_timer_started = true
	return _timer


## 取消当前计时器。
func cancel_timer() -> void:
	if _timer_started:
		_timer.paused = true
		_timer.timeout.emit()
		_timer.paused = false


## 检查计时器是否已被取消。
##
## 返回: [bool] 是否已取消
func is_timer_canceled() -> bool:
	return _timer.paused


## 等待指定数量的物理帧。
##
## 参数:
##   tick_count: 要等待的物理帧数
##
## 返回: [Test] 自身引用（支持链式调用）
func wait_for_physics_ticks(tick_count: int) -> Test:
	_wait_physics_ticks_counter = tick_count
	return self


func _on_timer_done() -> void:
	_timer_started = false
