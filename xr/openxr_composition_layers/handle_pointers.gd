## 合成层指针处理器 —— 将 XR 控制器的射线交互转换为视口输入事件。
## 继承自 [OpenXRCompositionLayerEquirect]，通过射线检测将控制器交互
## 转换为鼠标事件传递给合成层视口。
extends OpenXRCompositionLayerEquirect

## 无交点标记常量。
const NO_INTERSECTION = Vector2(-1.0, -1.0)

## 绑定的 XR 控制器节点。
@export var controller : XRController3D
## 触发交互的按钮操作名称。
@export var button_action : String = "select"

## 上一帧按钮是否被按下。
var was_pressed : bool = false
## 上一帧的射线交点 UV 坐标。
var was_intersect : Vector2 = NO_INTERSECTION


## _input 输入处理 —— 将输入事件传递到合成层视口。
## 参数:
##   event: 输入事件
##
## 忽略桌面鼠标事件，其他事件传递到 [member layer_viewport]。
func _input(event):
	if not layer_viewport:
		return

	if event is InputEventMouse:
		# 桌面鼠标事件不传递
		return

	# 其他事件传递到合成层视口
	layer_viewport.push_input(event)


## 将射线交点 UV 坐标转换为视口像素坐标。
## 参数:
##   intersect: 射线交点 UV 坐标（0.0~1.0）
## 返回: [Vector2i] 视口像素坐标，无交点时返回 (-1, -1)
func _intersect_to_viewport_pos(intersect : Vector2) -> Vector2i:
	if layer_viewport and intersect != NO_INTERSECTION:
		var pos : Vector2 = intersect * Vector2(layer_viewport.size)
		return Vector2i(pos)
	else:
		return Vector2i(-1, -1)


## _process 每帧更新 —— 检测射线交点并生成鼠标事件。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 从控制器发射射线检测与合成层的交点
##   2. 如果有交点，生成 [InputEventMouseMotion] 事件
##   3. 检测按钮按下/释放状态变化，生成 [InputEventMouseButton] 事件
##   4. 将事件推送到合成层视口
func _process(_delta):
	if not controller:
		return
	if not layer_viewport:
		return

	var controller_t : Transform3D = controller.global_transform
	var intersect : Vector2 = intersects_ray(controller_t.origin, -controller_t.basis.z)

	if intersect != NO_INTERSECTION:
		var is_pressed : bool = controller.is_button_pressed(button_action)

		if was_intersect != NO_INTERSECTION and intersect != was_intersect:
			# 指针移动 —— 生成鼠标移动事件
			var event : InputEventMouseMotion = InputEventMouseMotion.new()
			var from : Vector2 = _intersect_to_viewport_pos(was_intersect)
			var to : Vector2 = _intersect_to_viewport_pos(intersect)
			if was_pressed:
				event.button_mask = MOUSE_BUTTON_MASK_LEFT
			event.relative = to - from
			event.position = to
			layer_viewport.push_input(event)

		if not is_pressed and was_pressed:
			# 按钮释放 —— 生成鼠标按钮释放事件
			var event : InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = false
			event.position = _intersect_to_viewport_pos(intersect)
			layer_viewport.push_input(event)

		elif is_pressed and not was_pressed:
			# 按钮按下 —— 生成鼠标按钮按下事件
			var event : InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
			event.pressed = true
			event.position = _intersect_to_viewport_pos(intersect)
			layer_viewport.push_input(event)

		was_pressed = is_pressed
		was_intersect = intersect

	else:
		was_pressed = false
		was_intersect = NO_INTERSECTION
