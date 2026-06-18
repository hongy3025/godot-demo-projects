## 拾取处理器节点 —— 检测范围内的可拾取物体并处理拾取/释放逻辑。
## 使用类名注册为 [code]PickupHandler3D[/code]。
## 继承自 [Area3D]，检测所有 [PickupAbleBody3D] 类型的物理体，
## 选择最近的物体并允许用户拾取。
@tool
class_name PickupHandler3D
extends Area3D

## 检测范围半径，在此范围内检测可拾取物体。
@export var detect_range : float = 0.3:
	set(value):
		detect_range = value
		if is_inside_tree():
			_update_detect_range()
			_update_closest_body()

## 拾取操作名称，对应 OpenXR 操作映射中的操作。
@export var pickup_action : String = "pickup"

## 当前最近的（未拾取的）可拾取物体。
var closest_body : PickupAbleBody3D
## 当前已拾取的物体。
var picked_up_body: PickupAbleBody3D
## 上一帧拾取按钮是否被按下。
var was_pickup_pressed : bool = false


## 更新检测范围 —— 修改碰撞形状的半径。
func _update_detect_range() -> void:
	var shape : SphereShape3D = $CollisionShape3D.shape
	if shape:
		shape.radius = detect_range


## 更新最近的物体 —— 在重叠的物理体中查找最近的 [PickupAbleBody3D]。
## 如果已拾取物体则不更新。
func _update_closest_body() -> void:
	# 编辑器中不执行
	if Engine.is_editor_hint():
		return

	# 已拾取物体时清除最近物体标记
	if picked_up_body:
		if closest_body:
			closest_body.remove_is_closest(self)
			closest_body = null

		return

	# 查找最近的未拾取物体
	var new_closest_body : PickupAbleBody3D
	var closest_distance : float = 1000000.0

	for body in get_overlapping_bodies():
		if body is PickupAbleBody3D and not body.is_picked_up():
			var distance_squared = (body.global_position - global_position).length_squared()
			if distance_squared < closest_distance:
				new_closest_body = body
				closest_distance = distance_squared

	# 未变化则退出
	if closest_body == new_closest_body:
		return

	# 移除旧最近物体的标记
	if closest_body:
		closest_body.remove_is_closest(self)

	closest_body = new_closest_body
	if closest_body:
		closest_body.add_is_closest(self)


## 获取父 XRController3D 节点。
## 返回: [XRController3D] 或 null
func _get_parent_controller() -> XRController3D:
	var parent : Node = get_parent()
	while parent:
		if parent is XRController3D:
			return parent

		parent = parent.get_parent()

	return null


## _ready 初始化 —— 更新检测范围和最近物体。
func _ready() -> void:
	_update_detect_range()
	_update_closest_body()


## _physics_process 物理帧更新 —— 处理拾取/释放逻辑。
## 参数:
##   delta: 物理帧时间间隔（秒）
##
## 逻辑:
##   1. 更新最近物体（手移动后最近物体可能变化）
##   2. 读取拾取操作值，使用迟滞阈值避免抖动
##   3. 如果已拾取且按钮释放，释放物体
##   4. 如果未拾取且按钮按下且有最近物体，拾取物体
func _physics_process(delta) -> void:
	# 手移动后更新最近物体
	_update_closest_body()

	# 检查拾取操作是否被按下
	var pickup_pressed = false
	var controller : XRController3D = _get_parent_controller()
	if controller:
		# OpenXR 返回布尔值，但不同平台阈值差异大，自行实现阈值逻辑
		var pickup_value : float = controller.get_float(pickup_action)
		var threshold : float = 0.4 if was_pickup_pressed else 0.6
		pickup_pressed = pickup_value > threshold

	# 释放物体
	if picked_up_body and not pickup_pressed:
		picked_up_body.let_go()
		picked_up_body = null

	# 拾取物体
	if not picked_up_body and not was_pickup_pressed and pickup_pressed and closest_body:
		picked_up_body = closest_body
		picked_up_body.pick_up(self)

	# 记录当前状态供下一帧使用
	was_pickup_pressed = pickup_pressed
