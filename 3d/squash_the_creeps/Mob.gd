## 怪物角色 —— 自动朝玩家方向移动的敌人。
##
## 继承自 [CharacterBody3D]，在初始化时设置朝向和速度，
## 被玩家踩到时发出 squashed 信号并销毁。
extends CharacterBody3D

# 当玩家踩到怪物时发出的信号。
signal squashed

## 怪物最小速度（米/秒）。
@export var min_speed = 10
## 怪物最大速度（米/秒）。
@export var max_speed = 18


## _physics_process 入口。每物理帧执行移动。
func _physics_process(_delta):
	move_and_slide()


## 初始化怪物。设置朝向、随机速度和动画速度。
##
## 参数:
##   start_position: 生成位置
##   player_position: 玩家位置
##
## 核心逻辑：
## 1. 朝向玩家方向
## 2. 在 ±45 度范围内随机偏转，使怪物不会全部直冲玩家
## 3. 在最小/最大速度范围内随机选择速度
## 4. 根据速度调整动画播放速度
func initialize(start_position, player_position):
	# 忽略玩家的高度，防止玩家跳跃时怪物朝向发生轻微偏移。
	var target = Vector3(player_position.x, start_position.y, player_position.z)
	look_at_from_position(start_position, target, Vector3.UP)

	# 在 -45 到 +45 度范围内随机旋转，使怪物不会直接朝向玩家。
	rotate_y(randf_range(-PI / 4, PI / 4))

	var random_speed = randf_range(min_speed, max_speed)
	# 先计算前向速度。
	velocity = Vector3.FORWARD * random_speed
	# 根据怪物的 Y 轴旋转旋转速度向量，使其朝向面对的方向移动。
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	$AnimationPlayer.speed_scale = random_speed / min_speed


## 被踩扁。发出信号并销毁。
func squash():
	squashed.emit()
	queue_free()


## 屏幕可见性通知回调。怪物离开屏幕时自动销毁。
func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
