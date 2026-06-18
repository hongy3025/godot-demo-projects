## 乒乓球拍控制逻辑 —— 处理玩家输入、网络同步和碰撞响应。
##
## 继承自 [Area2D]，作为乒乓球拍节点。
## 使用 @rpc("unreliable") 实现位置和速度的快速网络同步，
## 即使某些数据包丢失也能保证流畅体验。
extends Area2D

## 球拍移动速度（像素/秒）。
const MOTION_SPEED = 150

## 是否为左侧球拍。通过 @export 暴露给编辑器设置。
@export var left: bool = false

## 当前运动方向（-1 向上，1 向下，0 静止）。
var _motion := 0.0
## "You" 标签是否已隐藏。
var _you_hidden: bool = false

## 屏幕高度，用于限制球拍移动范围。
@onready var _screen_size_y := get_viewport_rect().size.y


## _process 每帧处理：读取输入、同步位置、限制边界。
##
## 网络权限方：读取输入、通过 RPC 同步位置。
## 非权限方：仅隐藏提示标签。
## 双方都执行 translate 以实现本地预测。
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_motion = Input.get_axis(&"move_up", &"move_down")

		if not _you_hidden and _motion != 0:
			_hide_you_label()

		_motion *= MOTION_SPEED

		# 使用 unreliable 模式确保位置更新尽可能快，即使某个调用被丢弃也没关系。
		set_pos_and_motion.rpc(position, _motion)
	else:
		if not _you_hidden:
			_hide_you_label()

	translate(Vector2(0.0, _motion * delta))

	# 限制球拍在屏幕边界内。
	position.y = clampf(position.y, 16, _screen_size_y - 16)


## 同步位置和速度到其他对等端。使用 unreliable 模式以获得最佳性能。
## 参数 pos: 位置向量；motion: 运动速度。
@rpc("unreliable")
func set_pos_and_motion(pos: Vector2, motion: float) -> void:
	position = pos
	_motion = motion


## 隐藏 "You" 提示标签。
func _hide_you_label() -> void:
	_you_hidden = true
	$You.hide()


## 球拍区域进入检测：当球碰到球拍时触发反弹。
## 参数 area: 进入区域的 Area2D（即球）。
func _on_paddle_area_enter(area: Area2D) -> void:
	if is_multiplayer_authority():
		# 生成随机方向，每个对等端各自计算。
		area.bounce.rpc(left, randf())
