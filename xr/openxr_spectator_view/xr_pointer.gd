## XR 指针节点 —— 实现 VR 中的射线指向交互。
## 继承自 [RayCast3D]，使用类名注册为 [code]XRPointer[/code]。
## 检测射线碰撞到的物体，并通过 _enter_pointer / _exit_pointer / _moved_pointer
## 方法回调通知目标物体。
class_name XRPointer
extends RayCast3D

## 当前指向的物体节点。
var pointing_at: Node3D
## 当前碰撞点的世界坐标。
var colliding_at: Vector3 = Vector3()


## _process 每帧更新 —— 处理射线检测和指针交互回调。
## 参数:
##   _delta: 上一帧到当前帧的时间间隔（秒）
##
## 逻辑:
##   1. 控制激光和瞄准点的可见性
##   2. 如果启用且碰撞到物体，更新瞄准点位置
##   3. 当指针进入/离开/移动时调用目标物体的对应方法
func _process(_delta):
	# 控制激光可见性
	$Laser.visible = enabled

	var col_with: Node3D
	var col_at: Vector3 = Vector3()

	if enabled:
		if is_colliding():
			col_with = get_collider()
			col_at = get_collision_point()
			$Target.global_position = col_at
			$Target.visible = true
		else:
			$Target.visible = false
	else:
		$Target.visible = false

	# 指针离开旧物体时调用 _exit_pointer
	if pointing_at and pointing_at != col_with:
		if pointing_at.has_method(&"_exit_pointer"):
			pointing_at._exit_pointer(self, colliding_at)
		pointing_at = null

	# 指针进入新物体时调用 _enter_pointer
	if col_with and not pointing_at:
		pointing_at = col_with
		colliding_at = col_at
		if pointing_at.has_method(&"_enter_pointer"):
			pointing_at._enter_pointer(self, colliding_at)

	# 指针在物体上移动时调用 _moved_pointer
	if pointing_at and colliding_at != col_at:
		if pointing_at.has_method(&"_moved_pointer"):
			pointing_at._moved_pointer(self, colliding_at, col_at)
		colliding_at = col_at
