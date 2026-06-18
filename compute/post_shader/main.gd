## 后期处理演示场景的主控制节点 —— 切换灰度/着色器效果的开关。
##
## 继承自 [Node3D]，监听键盘输入来启用或禁用两种后期处理效果，
## 并在屏幕上显示当前效果的启用状态。
extends Node3D

## 合成器对象引用，用于控制合成器效果的启用/禁用
@onready var compositor: Compositor = $WorldEnvironment.compositor


## 输入事件处理。监听按键切换灰度效果和着色器效果的开关。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_grayscale_effect"):
		compositor.compositor_effects[0].enabled = not compositor.compositor_effects[0].enabled
		update_info_text()

	if input_event.is_action_pressed(&"toggle_shader_effect"):
		compositor.compositor_effects[1].enabled = not compositor.compositor_effects[1].enabled
		update_info_text()


## 更新屏幕上的效果状态文本。
func update_info_text() -> void:
	$Info.text = """灰度效果：%s
着色器效果：%s
""" % [
	"已启用" if compositor.compositor_effects[0].enabled else "已禁用",
	"已启用" if compositor.compositor_effects[1].enabled else "已禁用",
]
