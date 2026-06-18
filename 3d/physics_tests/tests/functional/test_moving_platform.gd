## 移动平台测试 —— 测试不同角色类型在移动平台上的表现。
extends Test


const OPTION_BODY_TYPE = "物体类型/%s (%d)"

const OPTION_SLOPE = "物理选项/斜坡停止（仅角色）"
const OPTION_SNAP = "物理选项/使用吸附（仅角色）"
const OPTION_FRICTION = "物理选项/摩擦力（仅刚体）"
const OPTION_ROUGH = "物理选项/粗糙（仅刚体）"
const OPTION_PROCESS_PHYSICS = "物理选项/动画播放器物理处理模式"

const SHAPE_CAPSULE = "碰撞形状/胶囊"
const SHAPE_BOX = "碰撞形状/盒子"
const SHAPE_CYLINDER = "碰撞形状/圆柱"
const SHAPE_SPHERE = "碰撞形状/球体"
const SHAPE_CONVEX = "碰撞形状/凸多边形"

var _slope: bool = false
var _snap: bool = false
var _friction: bool = false
var _rough: bool = false
var _animation_physics: bool = false

var _body_scene := {}
var _key_list := []
var _current_body_index := 0
var _current_body_key: String = ""
var _current_body: PhysicsBody3D = null
var _body_type := ["CharacterBody3D", "RigidBody"]

var _shapes := {}
var _current_shape: String = ""


func _ready() -> void:
	var options: OptionMenu = $Options
	var bodies := $Bodies.get_children()
	for i in bodies.size():
		var body := bodies[i]
		var option_name := OPTION_BODY_TYPE % [body.name, i + 1]
		options.add_menu_item(option_name)
		_key_list.append(option_name)
		_body_scene[option_name] = get_packed_scene(body)
		body.queue_free()

	options.add_menu_item(SHAPE_CAPSULE)
	options.add_menu_item(SHAPE_BOX)
	options.add_menu_item(SHAPE_CYLINDER)
	options.add_menu_item(SHAPE_SPHERE)
	options.add_menu_item(SHAPE_CONVEX)

	options.add_menu_item(OPTION_SLOPE, true, false)
	options.add_menu_item(OPTION_SNAP, true, false)
	options.add_menu_item(OPTION_FRICTION, true, false)
	options.add_menu_item(OPTION_ROUGH, true, false)
	options.add_menu_item(OPTION_PROCESS_PHYSICS, true, false)

	options.option_selected.connect(_on_option_selected)
	options.option_changed.connect(_on_option_changed)

	_shapes[SHAPE_CAPSULE] = "Capsule"
	_shapes[SHAPE_BOX] = "Box"
	_shapes[SHAPE_CYLINDER] = "Cylinder"
	_shapes[SHAPE_SPHERE] = "Sphere"
	_shapes[SHAPE_CONVEX] = "Convex"
	_current_shape = _shapes[SHAPE_CAPSULE]

	spawn_body_index(_current_body_index)


func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey and not input_event.pressed:
		var _index: int = input_event.keycode - KEY_1
		if _index >= 0 and _index < _key_list.size():
			spawn_body_index(_index)


func _on_option_selected(option: String) -> void:
	if _body_scene.has(option):
		spawn_body_key(option)
	else:
		match option:
			SHAPE_CAPSULE:
				_current_shape = _shapes[SHAPE_CAPSULE]
				spawn_body_index(_current_body_index)
			SHAPE_BOX:
				_current_shape = _shapes[SHAPE_BOX]
				spawn_body_index(_current_body_index)
			SHAPE_CYLINDER:
				_current_shape = _shapes[SHAPE_CYLINDER]
				spawn_body_index(_current_body_index)
			SHAPE_SPHERE:
				_current_shape = _shapes[SHAPE_SPHERE]
				spawn_body_index(_current_body_index)
			SHAPE_CONVEX:
				_current_shape = _shapes[SHAPE_CONVEX]
				spawn_body_index(_current_body_index)


func _on_option_changed(option: String, checked: bool) -> void:
	match option:
		OPTION_SLOPE:
			_slope = checked
			spawn_body_index(_current_body_index)
		OPTION_SNAP:
			_snap = checked
			spawn_body_index(_current_body_index)
		OPTION_FRICTION:
			_friction = checked
			spawn_body_index(_current_body_index)
		OPTION_ROUGH:
			_rough = checked
			spawn_body_index(_current_body_index)
		OPTION_PROCESS_PHYSICS:
			_animation_physics = checked
			spawn_body_index(_current_body_index)


func spawn_body_index(body_index: int) -> void:
	if _current_body:
		_current_body.queue_free()
	_current_body_index = body_index
	_current_body_key = _key_list[body_index]
	var body_parent := $Bodies
	var body: PhysicsBody3D = _body_scene[_key_list[body_index]].instantiate()
	_current_body = body
	init_body()
	body_parent.add_child(body)
	start_test()


func spawn_body_key(body_key: String) -> void:
	if _current_body:
		_current_body.queue_free()
	_current_body_key = body_key
	_current_body_index = _key_list.find(body_key)
	var body_parent := $Bodies
	var body: PhysicsBody3D = _body_scene[body_key].instantiate()
	_current_body = body
	init_body()
	body_parent.add_child(body)
	start_test()


func init_body() -> void:
	if _current_body is CharacterBody3D:
		_current_body._stop_on_slopes = _slope
		_current_body.use_snap = _snap
	elif _current_body is RigidBody3D:
		_current_body.physics_material_override.rough = _rough
		_current_body.physics_material_override.friction = 1.0 if _friction else 0.0
	for shape in _current_body.get_children():
		if shape is CollisionShape3D:
			if shape.name != _current_shape:
				shape.queue_free()


func start_test() -> void:
	var animation_player: AnimationPlayer = $Platforms/MovingPlatform/AnimationPlayer
	animation_player.stop()
	if _animation_physics:
		animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	else:
		animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_IDLE
	animation_player.play(&"Move")

	$LabelBodyType.text = "物体类型: " + _body_type[_current_body_index] + " \n碰撞形状: " + _current_shape


func get_packed_scene(node: Node) -> PackedScene:
	for child in node.get_children():
		child.owner = node

	var packed_scene := PackedScene.new()
	packed_scene.pack(node)
	return packed_scene
