## 刚体地面检测测试 —— 测试不同形状刚体在不同地面上的地面检测。
extends Test


const OPTION_BIG = "地面选项/大"
const OPTION_SMALL = "地面选项/小"

const SHAPE_CONCAVE = "碰撞形状/凹多边形"
const SHAPE_CONVEX = "碰撞形状/凸多边形"
const SHAPE_BOX = "碰撞形状/盒子"

var _dynamic_shapes_scene: PackedScene
var _floor_shapes: Dictionary[String, PackedScene] = {}
var _floor_size: String = "Small"

var _current_floor_name := SHAPE_CONCAVE
var _current_bodies: Node3D
var _current_floor: Node3D


func _ready() -> void:
	var options: OptionMenu = $Options
	_dynamic_shapes_scene = get_packed_scene($DynamicShapes/Bodies)
	_floor_shapes[SHAPE_CONVEX + "Small"] = get_packed_scene($"Floors/ConvexSmall")
	_floor_shapes[SHAPE_CONVEX + "Big"] = get_packed_scene($"Floors/ConvexBig")
	_floor_shapes[SHAPE_CONCAVE + "Big"] = get_packed_scene($"Floors/ConcaveBig")
	_floor_shapes[SHAPE_CONCAVE + "Small"] = get_packed_scene($"Floors/ConcaveSmall")
	_floor_shapes[SHAPE_BOX + "Big"] = get_packed_scene($"Floors/BoxBig")
	_floor_shapes[SHAPE_BOX + "Small"] = get_packed_scene($"Floors/BoxSmall")
	$DynamicShapes/Bodies.queue_free()
	for floorNode in $Floors.get_children():
		floorNode.queue_free()

	options.add_menu_item(OPTION_SMALL)
	options.add_menu_item(OPTION_BIG)
	options.add_menu_item(SHAPE_CONCAVE)
	options.add_menu_item(SHAPE_CONVEX)
	options.add_menu_item(SHAPE_BOX)

	options.option_selected.connect(_on_option_selected)
	restart_scene()


func _on_option_selected(option: String) -> void:
	match option:
		OPTION_BIG:
			_floor_size = "Big"
		OPTION_SMALL:
			_floor_size = "Small"
		_:
			_current_floor_name = option
	restart_scene()


func restart_scene() -> void:
	if _current_bodies:
		_current_bodies.queue_free()
	if _current_floor:
		_current_floor.queue_free()

	var dynamic_bodies := _dynamic_shapes_scene.instantiate()
	_current_bodies = dynamic_bodies
	add_child(dynamic_bodies)

	var floor_inst: Node3D = _floor_shapes[_current_floor_name + _floor_size].instantiate()
	_current_floor = floor_inst
	$Floors.add_child(floor_inst)

	$LabelBodyType.text = "地面类型: " + _current_floor_name.rsplit("/", true, 1)[1] + "\n大小: " + _floor_size


func get_packed_scene(node: Node) -> PackedScene:
	for child in node.get_children():
		child.owner = node
		for child1 in child.get_children():
			child1.owner = node
			for child2 in child1.get_children():
				child2.owner = node

	var packed_scene := PackedScene.new()
	packed_scene.pack(node)
	return packed_scene
