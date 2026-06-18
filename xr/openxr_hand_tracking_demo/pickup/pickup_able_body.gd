## 可拾取物理体节点 —— 支持被 [PickupHandler3D] 拾取的刚体。
## 使用类名注册为 [code]PickupAbleBody3D[/code]。
## 继承自 [RigidBody3D]，处理拾取/释放逻辑、高亮显示和缓动动画。
class_name PickupAbleBody3D
extends RigidBody3D

## 高亮材质，当物体成为最近可拾取物体时应用。
var highlight_material : Material = preload("res://shaders/highlight_material.tres")
## 拾取此物体的 [Area3D]（即 [PickupHandler3D]）。
var picked_up_by : Area3D
## 标记此物体为最近的 [Area3D] 列表。
var closest_areas : Array

## 拾取前的父节点，释放时恢复。
var original_parent : Node3D
## 缓动动画，用于拾取时的平滑过渡。
var tween : Tween


## 添加最近区域标记 —— 当此物体成为某个区域内的最近物体时调用。
## 参数:
##   area: 标记此物体为最近的区域
func add_is_closest(area : Area3D) -> void:
	if not closest_areas.has(area):
		closest_areas.push_back(area)

	_update_highlight()


## 移除最近区域标记 —— 当此物体不再是某个区域内的最近物体时调用。
## 参数:
##   area: 移除标记的区域
func remove_is_closest(area : Area3D) -> void:
	if closest_areas.has(area):
		closest_areas.erase(area)

	_update_highlight()


## 检查物体是否已被拾取。
## 返回: [bool] 是否已被拾取
func is_picked_up() -> bool:
	if picked_up_by:
		return true

	return false


## 拾取此物体。
## 参数:
##   pick_up_by: 执行拾取的 [Area3D]（[PickupHandler3D]）
##
## 逻辑:
##   1. 如果已被同一物体拾取则忽略
##   2. 如果被其他物体拾取则先释放
##   3. 从原父节点移除，添加到拾取器
##   4. 冻结刚体，执行缓动动画
func pick_up(pick_up_by) -> void:
	# 已拾取处理
	if picked_up_by:
		if picked_up_by == pick_up_by:
			return

		let_go()

	# 保存状态用于释放时恢复
	original_parent = get_parent()
	var current_transform = global_transform

	# 从原父节点移除
	original_parent.remove_child(self)

	# 执行拾取
	picked_up_by = pick_up_by
	picked_up_by.add_child(self)
	global_transform = current_transform
	freeze = true

	# 创建缓动动画
	if tween:
		tween.kill()
	tween = create_tween()

	# 计算吸附变换（此处为空实现，可添加自定义吸附逻辑）
	var snap_to : Transform3D

	# 执行缓动
	tween.tween_property(self, ^"transform", snap_to, 0.1)


## 释放此物体。
## 逻辑:
##   1. 从拾取器移除
##   2. 恢复到原父节点
##   3. 解冻刚体
func let_go() -> void:
	if not picked_up_by:
		return

	# 取消缓动动画
	if tween:
		tween.kill()
		tween = null

	# 保存当前变换
	var current_transform = global_transform

	# 从拾取器移除
	picked_up_by.remove_child(self)
	picked_up_by = null

	# 恢复到原父节点
	original_parent.add_child(self)
	global_transform = current_transform
	freeze = false


## 更新高亮显示 —— 当物体是某个区域的最近物体时显示高亮。
func _update_highlight() -> void:
	if not picked_up_by and not closest_areas.is_empty():
		# 添加高亮材质
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance : MeshInstance3D = child
				mesh_instance.material_overlay = highlight_material
	else:
		# 移除高亮材质
		for child in get_children():
			if child is MeshInstance3D:
				var mesh_instance : MeshInstance3D = child
				mesh_instance.material_overlay = null
