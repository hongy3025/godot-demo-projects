## 手势控制区域 —— 通过触摸手势控制 3D 物体的旋转和缩放。
##
## 该脚本继承自 [Control]，用于捕获触摸输入并转换为 3D 物体的变换操作。
## 支持单指旋转（绕 X/Y 轴）和双指缩放/旋转（绕 Z 轴）。
## 通过 @export 变量可以灵活启用/禁用各种手势功能。
extends Control

## 目标节点的 NodePath，脚本将对该节点应用变换操作。
@export var target: NodePath
## 最小缩放比例限制，防止物体缩放过小。
@export var min_scale := 0.1
## 最大缩放比例限制，防止物体缩放过大。
@export var max_scale := 3.0
## 是否启用单指绕 X 轴旋转（水平滑动）。
@export var one_finger_rot_x: bool = true
## 是否启用单指绕 Y 轴旋转（垂直滑动）。
@export var one_finger_rot_y: bool = true
## 是否启用双指绕 Z 轴旋转（双指旋转手势）。
@export var two_fingers_rot_z: bool = true
## 是否启用双指缩放（捏合手势）。
@export var two_fingers_zoom: bool = true

## 手指数量变化前的基准状态字典，用于避免累积误差。
## 键为触摸索引，值为触摸位置。
var base_state := {}
## 当前帧的触摸状态字典，键为触摸索引，值为触摸位置。
var curr_state := {}

## 手指数量变化前目标节点的变换副本，用于避免累积误差。
var base_xform: Transform3D

## 在场景就绪后获取目标节点的引用。
@onready var target_node: Node = get_node(target)


## 处理 GUI 输入事件 —— 将触摸手势转换为 3D 物体的旋转和缩放。
##
## 功能：根据当前触摸手指数量，分别处理单指旋转和双指缩放/旋转。
## 参数：
##   input_event: 输入事件对象（InputEvent）
## 返回值：无
## 逻辑：
##   - 0 指：接受触摸按下，记录基准状态
##   - 1 指：处理绕 X/Y 轴的旋转，支持添加第二指或抬起
##   - 2 指：处理双指缩放（捏合）和绕 Z 轴旋转
##   手指数量变化时，重置基准状态和变换副本以避免累积误差。
func _gui_input(input_event: InputEvent) -> void:

	var finger_count := base_state.size()

	if finger_count == 0:
		# 无触摸手指：接受触摸按下事件
		if input_event is InputEventScreenTouch:
			if input_event.pressed:
				# 有手指开始触摸，记录基准状态
				base_state = {
					input_event.index: input_event.position,
				}

	elif finger_count == 1:
		# 单指模式：处理绕 X 轴和 Y 轴的旋转
		# 接受新增触摸、触摸抬起或拖拽事件
		if input_event is InputEventScreenTouch:
			if input_event.pressed:
				# 第二根手指开始触摸，切换到双指模式
				# 将当前状态和新增手指设为基准状态
				base_state = {
					curr_state.keys()[0]: curr_state.values()[0],
					input_event.index: input_event.position,
				}
			else:
				if base_state.has(input_event.index):
					# 唯一触摸的手指抬起，清空基准状态
					base_state.clear()

		elif input_event is InputEventScreenDrag:
			if curr_state.has(input_event.index):
				# 触摸手指拖拽，计算拖拽偏移并旋转目标
				var unit_drag := _px2unit(base_state[base_state.keys()[0]] - input_event.position)
				if one_finger_rot_x:
					target_node.global_rotate(Vector3.UP, deg_to_rad(180.0 * unit_drag.x))
				if one_finger_rot_y:
					target_node.global_rotate(Vector3.RIGHT, deg_to_rad(180.0 * unit_drag.y))
				# 由于绕两个轴旋转，需要持续重置基准状态
				curr_state[input_event.index] = input_event.position
				base_state[input_event.index] = input_event.position
				base_xform = target_node.get_transform()

	elif finger_count == 2:
		# 双指模式：处理捏合缩放和绕 Z 轴旋转
		# 接受触摸抬起或拖拽事件
		if input_event is InputEventScreenTouch:
			if not input_event.pressed and base_state.has(input_event.index):
				# 某根已知的手指抬起，清空基准状态
				base_state.clear()

		elif input_event is InputEventScreenDrag:
			if curr_state.has(input_event.index):
				# 某根已知的手指拖拽，更新当前状态
				curr_state[input_event.index] = input_event.position

				# 计算基准和当前的双指间距向量
				var base_segment: Vector3 = base_state[base_state.keys()[0]] - base_state[base_state.keys()[1]]
				var new_segment: Vector3 = curr_state[curr_state.keys()[0]] - curr_state[curr_state.keys()[1]]

				# 从基准变换矩阵中提取基准缩放值
				var base_scale := Vector3(base_xform.basis.x.x, base_xform.basis.y.y, base_xform.basis.z.z).length()

				if two_fingers_zoom:
					# 计算新的缩放值，限制在 min_scale 和 max_scale 之间
					var new_scale := clampf(base_scale * (new_segment.length() / base_segment.length()), min_scale, max_scale) / base_scale
					target_node.set_transform(base_xform.scaled(new_scale * Vector3.ONE))
				else:
					target_node.set_transform(base_xform)

				if two_fingers_rot_z:
					# 计算基准向量与当前向量的夹角，绕 Z 轴旋转
					var rot := new_segment.angle_to(base_segment)
					target_node.global_rotate(Vector3.BACK, rot)

	# 手指数量是否发生变化？
	if base_state.size() != finger_count:
		# 将新的基准状态复制到当前状态
		curr_state = {}
		for idx: int in base_state.keys():
			curr_state[idx] = base_state[idx]
		# 记录当前变换作为新的基准
		base_xform = target_node.get_transform()


## 将像素坐标转换为归一化单位。
##
## 功能：将像素向量除以较短边的长度，得到归一化的单位向量。
## 参数：
##   v: 像素向量（Vector2）
## 返回值：归一化后的向量（Vector2）
## 逻辑：以控件较短边的像素数作为单位长度进行归一化。
func _px2unit(v: Vector2) -> Vector2:
	var shortest := minf(get_size().x, get_size().y)
	return v * (1.0 / shortest)
