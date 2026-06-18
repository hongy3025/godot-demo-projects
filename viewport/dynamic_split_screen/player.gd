## 玩家控制器 —— 控制 3D 角色在场景中移动。
##
## 继承自 [CharacterBody3D]，使用物理系统处理移动和碰撞。
## 支持双人分屏输入，通过 player_id 区分玩家1和玩家2。
extends CharacterBody3D

## 玩家编号（1 或 2），用于区分不同的输入映射。
@export_range(1, 2) var player_id := 1
## 玩家移动速度。
@export var walk_speed := 2.0


## 物理帧更新：处理玩家输入并移动角色。
## 使用 Input.get_vector 获取 WASD/方向键的输入向量，
## 将输入方向应用到速度上，并施加摩擦力使移动更平滑。
func _physics_process(_delta: float) -> void:
	var move_direction := Input.get_vector(
			"move_left_player" + str(player_id),
			"move_right_player" + str(player_id),
			"move_up_player" + str(player_id),
			"move_down_player" + str(player_id),
		)
	# 将输入方向转换为速度增量
	velocity.x += move_direction.x * walk_speed
	velocity.z += move_direction.y * walk_speed

	# 施加摩擦力，使角色停止时逐渐减速
	velocity *= 0.9

	move_and_slide()
