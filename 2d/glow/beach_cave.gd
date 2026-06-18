## 发光效果演示 —— 洞穴场景的发光贴图切换。
## 继承自 Node2D，通过鼠标拖拽移动洞穴，键盘切换发光贴图。
extends Node2D


## 洞穴移动范围限制。
const CAVE_LIMIT = 1000

## 发光贴图资源。
var glow_map := preload("res://glow_map.webp")

## 洞穴节点引用。
@onready var cave: Node2D = $Cave


## 处理输入：鼠标拖拽移动洞穴，按键切换发光贴图。
func _unhandled_input(input_event: InputEvent) -> void:
	# 鼠标拖拽移动洞穴位置
	if input_event is InputEventMouseMotion and input_event.button_mask > 0:
		cave.position.x = clampf(cave.position.x + input_event.screen_relative.x, -CAVE_LIMIT, 0)

	# 切换发光贴图
	if input_event.is_action_pressed(&"toggle_glow_map"):
		if $WorldEnvironment.environment.glow_map:
			$WorldEnvironment.environment.glow_map = null
			$WorldEnvironment.environment.glow_intensity = 0.8
		else:
			$WorldEnvironment.environment.glow_map = glow_map
			$WorldEnvironment.environment.glow_intensity = 1.6
