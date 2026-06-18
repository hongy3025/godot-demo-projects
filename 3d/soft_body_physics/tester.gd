## 软体物理演示场景的主控制器。
##
## 继承自 [WorldEnvironment]，管理多个软体测试场景的切换、摄像机控制、
## 物理重置和额外物体生成。
extends WorldEnvironment


const ROT_SPEED: float = 0.003
const ZOOM_SPEED: float = 0.125
const MAIN_BUTTONS: int = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

## 可同时存在的额外布料和盒子的最大数量（性能考虑）。
const MAX_ADDITIONAL_ITEMS: int = 10

## 布料场景预加载。
const Cloth: PackedScene = preload("res://cloth.tscn")
## 轻质刚体盒子预加载。
const RigidBoxLight: PackedScene = preload("res://rigid_box_light.tscn")
## 重型刚体盒子预加载。
const RigidBoxHeavy: PackedScene = preload("res://rigid_box_heavy.tscn")
## 软体盒子预加载。
const Box: PackedScene = preload("res://box.tscn")
## 软体球体预加载。
const Sphere: PackedScene = preload("res://sphere.tscn")

## 当前测试场景的索引。
var tester_index: int = 0
## 摄像机 X 轴旋转角度。
var rot_x: float = deg_to_rad(-22.5)
## 摄像机 Y 轴旋转角度。
var rot_y: float = deg_to_rad(90.0)
## 摄像机缩放值。
var zoom: float = 1.5
## 窗口基础高度。
var base_height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))

## 玩家生成的额外物体列表。
var additional_items: Array[Node3D] = []

## 所有测试场景的父节点。
@onready var testers: Node3D = $Testers
## 摄像机支架。
@onready var camera_holder: Node3D = $CameraHolder
## 摄像机 X 轴旋转节点。
@onready var rotation_x: Node3D = $CameraHolder/RotationX
## 实际渲染用的 Camera3D。
@onready var camera: Camera3D = $CameraHolder/RotationX/Camera3D

## 可重置的软体节点列表。
@onready var nodes_to_reset: Array[SoftBody3D] = [
	$Testers/ClothPhysics/Cloth,
	$Testers/SoftBoxes/Box,
	$Testers/SoftBoxes/Box2,
	$Testers/SoftSpheres/Sphere,
	$Testers/SoftSpheres/Sphere2,
	$Testers/CentralImpulseTimer/Cloth,
	$Testers/PerPointImpulseTimer/Cloth,
	$Testers/CentralForceWind/Cloth,
	$Testers/PinnedPoints/PinnedCloth,
]

## 可重置节点对应的场景类型。
@onready var nodes_to_reset_types: Array[PackedScene] = [
	Cloth,
	Box,
	Box,
	Sphere,
	Sphere,
	Cloth,
	Cloth,
	Cloth,
	Cloth,
]

## 可重置节点的初始全局位置。
@onready var nodes_to_reset_global_positions: PackedVector3Array


func _ready() -> void:
	for node: Node3D in nodes_to_reset:
		nodes_to_reset_global_positions.push_back(node.global_position)

	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	update_gui()


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"ui_left"):
		_on_previous_pressed()
	if input_event.is_action_pressed(&"ui_right"):
		_on_next_pressed()

	if input_event.is_action_pressed(&"reset_physics_simulation"):
		for additional_item in additional_items:
			additional_item.queue_free()
		additional_items.clear()

		for idx in nodes_to_reset.size():
			var previous_name: String = nodes_to_reset[idx].name
			var previous_parent: Node = nodes_to_reset[idx].get_parent()
			nodes_to_reset[idx].queue_free()
			nodes_to_reset[idx] = nodes_to_reset_types[idx].instantiate()
			previous_parent.add_child(nodes_to_reset[idx])
			nodes_to_reset[idx].name = previous_name
			nodes_to_reset[idx].global_position = nodes_to_reset_global_positions[idx]
			if "PinnedCloth" in nodes_to_reset[idx].name:
				for point: int in [0, 64, 4160, 4224]:
					nodes_to_reset[idx].set_point_pinned(point, true)

	if (
			input_event.is_action_pressed(&"place_cloth") or
			input_event.is_action_pressed(&"place_light_box") or
			input_event.is_action_pressed(&"place_heavy_box")
	):
		var origin: Vector3 = camera.global_position
		var target: Vector3 = camera.project_position(get_viewport().get_mouse_position(), 100)

		var query := PhysicsRayQueryParameters3D.create(origin, target)
		query.collision_mask = 1
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			if additional_items.size() >= MAX_ADDITIONAL_ITEMS:
				additional_items.pop_front().queue_free()

			var node: Node3D
			if input_event.is_action_pressed(&"place_cloth"):
				node = Cloth.instantiate()
				node.transparency = 0.35
			elif input_event.is_action_pressed(&"place_light_box"):
				node = RigidBoxLight.instantiate()
			else:
				node = RigidBoxHeavy.instantiate()

			node.position = result["position"] + Vector3(0, 0.5, 0)
			add_child(node)
			additional_items.push_back(node)

	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if input_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 1.5, 4)

	if input_event is InputEventMouseMotion and input_event.button_mask & MAIN_BUTTONS:
		var relative_motion: Vector2 = input_event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, deg_to_rad(-90), 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


func _process(delta: float) -> void:
	var current_tester: Node3D = testers.get_child(tester_index)
	var current_position_z: float = camera_holder.global_transform.origin.z
	var target_position_z: float = current_tester.global_transform.origin.z
	camera_holder.global_transform.origin.z = lerpf(current_position_z, target_position_z, 3 * delta)
	camera.position.z = lerpf(camera.position.z, zoom, 10 * delta)


func _physics_process(delta: float) -> void:
	const WIND_FORCE: float = 2_450_000.0
	for node in $Testers/CentralForceWind.get_children():
		if node is SoftBody3D:
			node.apply_central_force(Vector3(1.0, 0.0, 0.0) * WIND_FORCE * delta)

	for cloth in $Testers/PerPointImpulseTimer.get_children():
		if cloth is SoftBody3D:
			for node in $Testers/PerPointImpulseTimer/PointTrackers.get_children():
				node.global_position = cloth.get_point_transform(node.get_meta(&"point")) + Vector3(0.0, 0.01, 0.0)


func _on_previous_pressed() -> void:
	tester_index = max(0, tester_index - 1)
	update_gui()


func _on_next_pressed() -> void:
	tester_index = min(tester_index + 1, testers.get_child_count() - 1)
	update_gui()


func update_gui() -> void:
	$TestName.text = str(testers.get_child(tester_index).name).capitalize()
	$Previous.disabled = tester_index == 0
	$Next.disabled = tester_index == testers.get_child_count() - 1


func _on_central_impulse_timer_timeout() -> void:
	const INTENSITY: float = 8000.0
	for node in $Testers/CentralImpulseTimer.get_children():
		if node is SoftBody3D:
			var random_unit_vector := Vector3(randf_range(-1.0, 1.0), randf_range(-0.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			node.apply_central_impulse(random_unit_vector * INTENSITY)


func _on_per_point_impulse_timer_timeout() -> void:
	const INTENSITY: float = 600.0
	for node in $Testers/PerPointImpulseTimer.get_children():
		if node is SoftBody3D:
			for point: int in [0, 64, 4160, 4224]:
				var random_unit_vector := Vector3(randf_range(-1.0, 1.0), randf_range(-0.0, 1.0), randf_range(-1.0, 1.0)).normalized()
				node.apply_impulse(point, random_unit_vector * INTENSITY)
