## 光照与阴影演示控制器。
## 继承自 Node2D，通过键盘输入切换光源可见性和阴影质量。
extends Node2D


## 处理输入事件，切换光源和阴影质量。
func _input(input_event: InputEvent) -> void:
	# 切换方向光的可见性
	if input_event.is_action_pressed(&"toggle_directional_light"):
		$DirectionalLight2D.visible = not $DirectionalLight2D.visible

	# 切换所有点光源的可见性（通过组 "point_light" 查找）
	if input_event.is_action_pressed(&"toggle_point_lights"):
		for point_light in get_tree().get_nodes_in_group(&"point_light"):
			point_light.visible = not point_light.visible

	# 循环切换方向光的阴影过滤质量（0-3 循环）
	if input_event.is_action_pressed(&"cycle_directional_light_shadows_quality"):
		$DirectionalLight2D.shadow_filter = wrapi($DirectionalLight2D.shadow_filter + 1, 0, 3)

	# 循环切换所有点光源的阴影过滤质量
	if input_event.is_action_pressed(&"cycle_point_light_shadows_quality"):
		for point_light in get_tree().get_nodes_in_group(&"point_light"):
			point_light.shadow_filter = wrapi(point_light.shadow_filter + 1, 0, 3)
