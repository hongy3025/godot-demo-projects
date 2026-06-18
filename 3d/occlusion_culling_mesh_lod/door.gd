## 遮挡剔除演示场景的门控制器。
##
## 继承自 [Node3D]，演示开门/关门时如何管理 OccluderInstance3D 的可见性。
## 开门时立即禁用遮挡体，关门动画完成后才重新启用遮挡体，
## 防止遮挡体位置每帧变化导致 BVH 树频繁重建。
extends Node3D

## 门是否处于打开状态。
var open: bool = false

## _input 入口。处理开门/关门快捷键。
##
## 参数:
##   input_event: 输入事件对象
##
## 核心逻辑：
## - 开门：播放开门动画，立即禁用遮挡体
## - 关门：反向播放动画，动画完成后重新启用遮挡体
func _input(input_event: InputEvent) -> void:
	if not input_event.is_action_pressed(&"toggle_doors"):
		return
	if open:
		# 关门。
		# 遮挡体将在动画结束时通过 `_on_animation_player_animation_finished()` 重新启用。
		$AnimationPlayer.play_backwards(&"open")
		open = false
	else:
		# 开门。
		$AnimationPlayer.play(&"open")
		open = true
		# 门开始打开时立即禁用遮挡体。
		# 遮挡体不在门枢轴内，防止其位置每帧变化导致遮挡剔除 BVH 树每帧重建（CPU 性能开销）。
		$OccluderInstance3D.visible = false


## 动画播放完成回调。关门完成后重新启用遮挡体。
##
## 参数:
##   _anim_name: 动画名称
##
## 为防止过度遮挡，必须在门完全关闭后才能重新启用遮挡体。
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if not open:
		# 门完全关闭后重新启用遮挡体。
		$OccluderInstance3D.visible = true
