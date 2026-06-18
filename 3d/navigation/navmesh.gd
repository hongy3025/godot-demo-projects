## 导航网格演示场景的主控制器。
##
## 继承自 [Node3D]，演示 NavigationAgent3D 的路径寻路功能。
## 鼠标左键点击导航网格上的位置，角色会自动寻路前往。
extends Node3D


## 预加载 Character 脚本。
const Character = preload("res://character.gd")

## 摄像机 Y 轴旋转角度。
var _cam_rotation := 0.0

## 场景中的 Camera3D 节点引用。
@onready var _camera := $CameraBase/Camera3D as Camera3D
## 机器人角色引用。
@onready var _robot := $RobotBase as Character


## _unhandled_input 入口。处理鼠标点击寻路和摄像机旋转。
##
## 参数:
##   input_event: 输入事件对象
##
## 核心逻辑：
## 1. 鼠标左键点击：从摄像机向鼠标位置发射射线，获取导航网格上的最近点
## 2. 鼠标中键/右键拖拽：旋转摄像机
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.button_index == MOUSE_BUTTON_LEFT and input_event.pressed:
		# 获取鼠标光标位置在导航网格上的最近点。
		var mouse_cursor_position: Vector2 = input_event.position
		var camera_ray_length := 1000.0
		var camera_ray_start := _camera.project_ray_origin(mouse_cursor_position)
		var camera_ray_end := camera_ray_start + _camera.project_ray_normal(mouse_cursor_position) * camera_ray_length

		var closest_point_on_navmesh := NavigationServer3D.map_get_closest_point_to_segment(
				get_world_3d().navigation_map,
				camera_ray_start,
				camera_ray_end
			)
		_robot.set_target_position(closest_point_on_navmesh)

	elif input_event is InputEventMouseMotion:
		if input_event.button_mask & (MOUSE_BUTTON_MASK_MIDDLE + MOUSE_BUTTON_MASK_RIGHT):
			_cam_rotation -= input_event.screen_relative.x * 0.005
			$CameraBase.set_rotation(Vector3.UP * _cam_rotation)
