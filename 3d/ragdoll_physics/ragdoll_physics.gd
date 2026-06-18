## 布娃娃物理演示场景的主控制器。
##
## 继承自 [Node3D]，支持在场景中放置布娃娃、重置模拟、慢动作和摄像机控制。
extends Node3D


## 鼠标灵敏度。
const MOUSE_SENSITIVITY = 0.01
## 布娃娃初始速度强度。
const INITIAL_VELOCITY_STRENGTH = 0.5

# 自动计算阴影最大距离的额外边距。
# 该值通过经验确定，可在最大缩放时覆盖整个场景。
const DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN = 9.0

## 摄像机枢轴节点。
@onready var camera_pivot: Node3D = $CameraPivot
## 摄像机节点。
@onready var camera: Camera3D = $CameraPivot/Camera3D
## 方向光节点。
@onready var directional_light: DirectionalLight3D = $DirectionalLight3D


## _unhandled_input 入口。处理布娃娃放置、重置、慢动作和摄像机控制。
##
## 参数:
##   input_event: 输入事件对象
##
## 功能：
## - reset_simulation: 重置场景
## - place_ragdoll: 在鼠标点击位置放置布娃娃
## - slow_motion: 按住时启用慢动作
## - 鼠标右键拖拽：旋转摄像机
## - 滚轮：缩放并调整阴影距离
func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"reset_simulation"):
		get_tree().reload_current_scene()

	if input_event.is_action_pressed(&"place_ragdoll"):
		var origin := camera.global_position
		var target := camera.project_position(get_viewport().get_mouse_position(), 100)

		var query := PhysicsRayQueryParameters3D.create(origin, target)
		var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

		if not result.is_empty():
			var ragdoll := preload("res://characters/mannequiny_ragdoll.tscn").instantiate()
			ragdoll.position = result["position"] + Vector3(0.0, 0.5, 0.0)
			# 新生成的布娃娃面向摄像机。
			ragdoll.rotation.y = camera_pivot.rotation.y
			# 在随机水平方向给予初始速度。
			ragdoll.initial_velocity = Vector3.FORWARD.rotated(Vector3.UP, randf_range(0, TAU)) * INITIAL_VELOCITY_STRENGTH
			add_child(ragdoll)

	if input_event.is_action_pressed(&"slow_motion"):
		Engine.time_scale = 0.25
		# 音高缩放不要太低，否则听起来很奇怪。
		# `0.5` 是 `0.25` 的平方根，效果良好。
		AudioServer.playback_speed_scale = 0.5

	if input_event.is_action_released(&"slow_motion"):
		Engine.time_scale = 1.0
		AudioServer.playback_speed_scale = 1.0

	# 鼠标右键拖拽旋转摄像机。
	if input_event is InputEventMouseMotion:
		var mouse_motion := input_event as InputEventMouseMotion
		if mouse_motion.button_mask & MOUSE_BUTTON_RIGHT:
			camera_pivot.global_rotation.x = clampf(camera_pivot.global_rotation.x - input_event.screen_relative.y * MOUSE_SENSITIVITY, -TAU * 0.249, TAU * 0.021)
			camera_pivot.global_rotation.y -= input_event.screen_relative.x * MOUSE_SENSITIVITY

	# 滚轮缩放，同时调整阴影最大距离以覆盖场景。
	if input_event is InputEventMouseButton:
		var mouse_button := input_event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.translate_object_local(Vector3.FORWARD * 0.5)
			directional_light.directional_shadow_max_distance = camera.position.length() + DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate_object_local(Vector3.BACK * 0.5)
			directional_light.directional_shadow_max_distance = camera.position.length() + DIRECTIONAL_SHADOW_MAX_DISTANCE_MARGIN
