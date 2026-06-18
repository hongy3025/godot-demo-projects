## 暂停与视觉效果控制 —— 管理粒子演示的暂停、拖尾和辉光效果。
##
## 提供键盘交互：暂停/恢复、切换拖尾模式、调整拖尾长度、切换辉光。
## 在兼容模式下自动调整辉光强度以补偿低动态范围。
extends Label


## 是否为 OpenGL 兼容模式渲染，影响辉光强度调整。
var is_compatibility: bool = false


## _ready 入口：检测渲染方法，兼容模式下显示提示并增强辉光强度。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		is_compatibility = true
		text = "Space: Pause/Resume\nG: Toggle glow\n\n\n"
		get_parent().get_node(^"UnsupportedLabel").visible = true
		# 提高辉光强度以补偿兼容模式下较低的动态范围
		get_node(^"../..").environment.glow_intensity = 4.0


## _input 入口：处理暂停、拖尾和辉光的键盘快捷键。
##
## 快捷键：
## - Space：暂停/恢复粒子动画
## - T：切换拖尾效果（兼容模式下不可用）
## - ]：增加拖尾长度（兼容模式下不可用）
## - [：减少拖尾长度（兼容模式下不可用）
## - G：切换辉光效果
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_pause"):
		get_tree().paused = not get_tree().paused

	# 暂停时切换拖尾类型会导致粒子消失，因此禁止在暂停时操作
	if not is_compatibility and input_event.is_action_pressed(&"toggle_trails"):
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_enabled = not particles.trail_enabled

	if not is_compatibility and input_event.is_action_pressed(&"increase_trail_length"):
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_lifetime = clampf(particles.trail_lifetime + 0.05, 0.1, 1.0)

	if not is_compatibility and input_event.is_action_pressed(&"decrease_trail_length"):
		for particles in get_tree().get_nodes_in_group(&"trailable_particles"):
			particles.trail_lifetime = clampf(particles.trail_lifetime - 0.05, 0.1, 1.0)

	if input_event.is_action_pressed(&"toggle_glow"):
		get_node(^"../..").environment.glow_enabled = not get_node(^"../..").environment.glow_enabled
