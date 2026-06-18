## 控制器状态显示节点 —— 可视化显示 XR 控制器的扳机、点击和方向键状态。
## 继承自 [Control]，用于在 UI 上实时展示控制器的各项输入值。
extends Control

## 绑定的 XR 控制器节点引用。
@export var controller: XRController3D

## 扳机输入值的滑动条显示节点。
@onready var trigger_input_node: HSlider = $VBoxContainer/TriggerInput/HSlider
## 扳机点击状态的复选框显示节点。
@onready var trigger_click_node: CheckBox = $VBoxContainer/TriggerInput/CheckBox
## 扳机释放阈值标签显示节点。
@onready var on_threshold_node: Label = $VBoxContainer/Thresholds/OnThreshold
## 扳机按下阈值标签显示节点。
@onready var off_threshold_node: Label = $VBoxContainer/Thresholds/OffThreshold

## 方向键"上"状态的复选框显示节点。
@onready var dpad_up_node: CheckBox = $VBoxContainer/DPadState/Up
## 方向键"下"状态的复选框显示节点。
@onready var dpad_down_node: CheckBox = $VBoxContainer/DPadState/Down
## 方向键"左"状态的复选框显示节点。
@onready var dpad_left_node: CheckBox = $VBoxContainer/DPadState/Left
## 方向键"右"状态的复选框显示节点。
@onready var dpad_right_node: CheckBox = $VBoxContainer/DPadState/Right

## 扳机释放时的阈值记录（按下时记录当前值的最小值）。
var off_trigger_threshold: float = 1.0
## 扳机按下时的阈值记录（释放时记录当前值的最大值）。
var on_trigger_threshold: float = 0.0


## _process 每帧更新 —— 读取控制器状态并更新 UI 显示。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 读取扳机模拟值和点击状态
##   2. 通过点击状态变化计算扳机的按下/释放阈值
##   3. 读取方向键四个方向的状态
func _process(_delta: float) -> void:
	if controller:
		# 读取扳机模拟输入值（0.0~1.0）
		var trigger_input = controller.get_float(&"trigger")
		trigger_input_node.value = trigger_input

		# 读取扳机点击按钮状态
		var trigger_click = controller.is_button_pressed(&"trigger_click")
		trigger_click_node.button_pressed = trigger_click

		# 计算阈值：按下时记录最小值，释放时记录最大值
		if trigger_click:
			off_trigger_threshold = min(off_trigger_threshold, trigger_input)
		else:
			on_trigger_threshold = max(on_trigger_threshold, trigger_input)

		# 更新阈值显示
		on_threshold_node.text = "On: %0.2f" % on_trigger_threshold
		off_threshold_node.text = "Off: %0.2f" % off_trigger_threshold

		# 读取方向键四个方向的状态
		dpad_up_node.button_pressed = controller.is_button_pressed(&"up")
		dpad_down_node.button_pressed = controller.is_button_pressed(&"down")
		dpad_left_node.button_pressed = controller.is_button_pressed(&"left")
		dpad_right_node.button_pressed = controller.is_button_pressed(&"right")
