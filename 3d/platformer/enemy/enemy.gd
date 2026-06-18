## 平台游戏敌人 —— 使用 RigidBody3D 的自主移动敌人。
##
## 继承自 [RigidBody3D]，通过 _integrate_forces 实现自主移动和碰撞响应。
## 使用两条射线检测地面和墙壁，实现基本的巡逻 AI。
extends RigidBody3D


## 加速度。
const ACCEL: float = 5.0
## 减速度。
const DEACCEL: float = 20.0
## 最大速度。
const MAX_SPEED: float = 2.0
## 旋转速度。
const ROT_SPEED: float = 1.0

## 上一帧是否在前进。
var prev_advance: bool = false
## 是否正在死亡。
var dying: bool = false
## 旋转方向。
var rot_dir: float = 4.0

## 重力向量（从项目设置读取）。
@onready var gravity := Vector3(
		ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
)

## 动画播放器引用。
@onready var _animation_player := $Enemy/AnimationPlayer as AnimationPlayer
## 地面检测射线。
@onready var _ray_floor := $Enemy/Skeleton/RayFloor as RayCast3D
## 墙壁检测射线。
@onready var _ray_wall := $Enemy/Skeleton/RayWall as RayCast3D


## _integrate_forces 入口。自定义物理积分，实现敌人移动和碰撞响应。
##
## 参数:
##   state: 物理体直接状态，用于读取/设置速度和接触信息
##
## 核心逻辑：
## 1. 应用重力
## 2. 检测与子弹的碰撞，触发死亡
## 3. 使用射线检测地面和墙壁，决定前进或转向
## 4. 应用加速/减速
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var delta := state.get_step()
	var lin_velocity := state.get_linear_velocity()
	var grav := state.get_total_gravity()
	# get_total_gravity 在前几帧返回零，导致错误。
	if grav.is_zero_approx():
		grav = gravity

	lin_velocity += grav * delta # 应用重力。
	var up := -grav.normalized()

	if dying:
		state.set_linear_velocity(lin_velocity)
		return

	# 检测与子弹的碰撞。
	for i in state.get_contact_count():
		var contact_collider := state.get_contact_collider_object(i)
		var contact_normal := state.get_contact_local_normal(i)

		if is_instance_valid(contact_collider):
			if contact_collider is Bullet and contact_collider.enabled:
				dying = true
				axis_lock_angular_x = false
				axis_lock_angular_y = false
				axis_lock_angular_z = false
				collision_layer = 0
				state.set_angular_velocity(-contact_normal.cross(up).normalized() * 33.0)
				_animation_player.play(&"impact")
				_animation_player.queue(&"extra/explode")
				contact_collider.enabled = false
				$SoundWalkLoop.stop()
				$SoundHit.play()
				return

	# 检测前方是否有地面且无墙壁。
	var advance: bool = _ray_floor.is_colliding() and not _ray_wall.is_colliding()

	var dir: Vector3 = ($Enemy/Skeleton as Node3D).get_transform().basis.z.normalized()
	var deaccel_dir: Vector3 = dir

	if advance:
		if dir.dot(lin_velocity) < MAX_SPEED:
			lin_velocity += dir * ACCEL * delta
		deaccel_dir = dir.cross(gravity).normalized()
	else:
		if prev_advance:
			rot_dir = 1

		dir = Basis(up, rot_dir * ROT_SPEED * (delta)) * dir
		$Enemy/Skeleton.set_transform(Transform3D().looking_at(-dir, up))

	var dspeed: float = deaccel_dir.dot(lin_velocity)
	dspeed -= DEACCEL * delta
	if dspeed < 0:
		dspeed = 0

	lin_velocity = lin_velocity - deaccel_dir * deaccel_dir.dot(lin_velocity) \
			+ deaccel_dir * dspeed

	state.set_linear_velocity(lin_velocity)
	prev_advance = advance


## 死亡动画完成后销毁敌人。
func _die() -> void:
	queue_free()
