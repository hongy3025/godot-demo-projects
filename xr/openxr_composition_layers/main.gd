## 合成层主节点 —— 管理左右手柄的指针切换和触觉反馈。
## 继承自 [Node3D]，处理手柄触发操作、指针可见性切换和能量脉冲动画。
extends Node3D

## 缓动动画对象，用于指针能量脉冲效果。
var tween : Tween
## 当前活动的手柄。
var active_hand : XRController3D


## _ready 初始化 —— 默认启用右手指针。
func _ready():
	$XROrigin3D/LeftHand/Pointer.visible = false
	$XROrigin3D/RightHand/Pointer.visible = true
	active_hand = $XROrigin3D/RightHand


## 更新指针能量级别 —— 缓动动画回调函数。
## 参数:
##   new_value: 新的能量值
func _update_energy(new_value : float):
	var pointer = active_hand.get_node(^"Pointer")
	var material : ShaderMaterial = pointer.material_override
	if material:
		material.set_shader_parameter(&"energy", new_value)


## 执行能量脉冲动画 —— 从 5.0 渐变到 1.0，持续 0.5 秒。
func _do_tween_energy():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_method(_update_energy, 5.0, 1.0, 0.5)


## 左手柄按钮按下回调 —— 切换到左手指针并触发脉冲。
## 参数:
##   action_name: 操作名称
func _on_left_hand_button_pressed(action_name):
	if action_name == "select":
		# 切换到左手指针
		$XROrigin3D/LeftHand/Pointer.visible = true
		$XROrigin3D/RightHand/Pointer.visible = false

		active_hand = $XROrigin3D/LeftHand
		$XROrigin3D/OpenXRCompositionLayerEquirect.controller = active_hand

		# 视觉脉冲效果
		_do_tween_energy()

		# 触觉反馈
		# 注意: frequence == 0.0 表示由 XR 运行时选择最优频率
		active_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)


## 右手柄按钮按下回调 —— 切换到右手指针并触发脉冲。
## 参数:
##   action_name: 操作名称
func _on_right_hand_button_pressed(action_name):
	if action_name == "select":
		# 切换到右手指针
		$XROrigin3D/LeftHand/Pointer.visible = false
		$XROrigin3D/RightHand/Pointer.visible = true

		active_hand = $XROrigin3D/RightHand
		$XROrigin3D/OpenXRCompositionLayerEquirect.controller = active_hand

		# 视觉脉冲效果
		_do_tween_energy()

		# 触觉反馈
		active_hand.trigger_haptic_pulse("haptic", 0.0, 1.0, 0.5, 0.0)
