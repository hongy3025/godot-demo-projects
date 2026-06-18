## 物理测试注册器 —— 注册所有可用的物理测试。
extends Node

var _tests: Array[Dictionary] = [
	{"id": "功能测试/形状", "path": "res://tests/functional/test_shapes.tscn"},
	{"id": "功能测试/复合形状", "path": "res://tests/functional/test_compound_shapes.tscn"},
	{"id": "功能测试/摩擦力", "path": "res://tests/functional/test_friction.tscn"},
	{"id": "功能测试/盒子堆叠", "path": "res://tests/functional/test_stack.tscn"},
	{"id": "功能测试/盒子金字塔", "path": "res://tests/functional/test_pyramid.tscn"},
	{"id": "功能测试/碰撞对", "path": "res://tests/functional/test_collision_pairs.tscn"},
	{"id": "功能测试/关节", "path": "res://tests/functional/test_joints.tscn"},
	{"id": "功能测试/射线投射", "path": "res://tests/functional/test_raycasting.tscn"},
	{"id": "功能测试/刚体碰撞", "path": "res://tests/functional/test_rigidbody_impact.tscn"},
	{"id": "功能测试/刚体地面检测", "path": "res://tests/functional/test_rigidbody_ground_check.tscn"},
	{"id": "功能测试/移动平台", "path": "res://tests/functional/test_moving_platform.tscn"},
	{"id": "性能测试/宽阶段", "path": "res://tests/performance/test_perf_broadphase.tscn"},
	{"id": "性能测试/接触点", "path": "res://tests/performance/test_perf_contacts.tscn"},
	{"id": "性能测试/接触岛", "path": "res://tests/performance/test_perf_contact_islands.tscn"},
]


func _ready() -> void:
	var test_menu: OptionMenu = $TestsMenu
	for test in _tests:
		test_menu.add_test(test.id, test.path)
