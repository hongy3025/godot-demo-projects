## 窗口管理演示 —— 观察者角色，处理第一人称视角的移动和鼠标控制。
##
## 继承自 [CharacterBody3D]，在 3D 场景中提供第一人称漫游功能。
## 支持 WASD 移动、鼠标拖拽旋转视角、窗口透明开关。
extends CharacterBody3D

## 状态枚举：MENU（菜单模式，鼠标可见）/ GRAB（抓取模式，鼠标锁定）
enum State {
	MENU,
	GRAB,
}

## 鼠标灵敏度
const MOUSE_SENSITIVITY = 3.0

## 鼠标旋转位置缓存
var r_pos := Vector2()
## 当前状态
var state := State.MENU

## 相机节点引用
@onready var camera: Camera3D = $Camera3D


## _process 入口，每帧处理抓取模式下的移动和视角旋转。
func _process(delta: float) -> void:
	if state != State.GRAB:
		return

	var x_movement := Input.get_axis(&"move_left", &"move_right")
	var z_movement := Input.get_axis(&"move_forward", &"move_backwards")
	var dir := direction(Vector3(x_movement, 0, z_movement))
	transform.origin += dir * 10 * delta

	# 缩放输入，通过缩放 delta 实现
	var d := delta * 0.1
	rotate(Vector3.UP, d * r_pos.x)  # 偏航
	camera.transform = camera.transform.rotated(Vector3.RIGHT, d * r_pos.y)  # 俯仰

	# 已处理完所有输入，重置为零
	r_pos = Vector2.ZERO


## _input 入口，处理鼠标移动和 ESC 切换鼠标模式。
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		# 使用 screen_relative 使灵敏度不受视口分辨率影响
		r_pos = -input_event.screen_relative * MOUSE_SENSITIVITY

	if input_event.is_action(&"ui_cancel") and input_event.is_pressed() and not input_event.is_echo():
		if state == State.GRAB:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = State.MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = State.GRAB


## 计算相机朝向方向上的移动向量。
func direction(vector: Vector3) -> Vector3:
	var v := camera.get_global_transform().basis * vector
	return v.normalized()


## 透明窗口切换按钮回调。
func _on_transparent_check_button_toggled(button_pressed: bool) -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_WINDOW_TRANSPARENCY):
		OS.alert("Window transparency is not supported by the current display server (%s)." % DisplayServer.get_name())
		return

	get_viewport().transparent_bg = button_pressed
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, button_pressed)
