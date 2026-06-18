## 游戏主控制器 —— 管理游戏状态、怪物生成、分数和音效。
extends Node

## 怪物场景的 PackedScene。
@export var mob_scene: PackedScene
## 当前分数。
var score

## 游戏结束：停止所有计时器，显示结束界面。
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


## 开始新游戏：清除所有怪物，重置分数和玩家位置。
func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


## 怪物生成计时器超时：在随机位置创建新怪物。
func _on_MobTimer_timeout():
	var mob = mob_scene.instantiate()

	# 在 Path2D 上选择随机位置
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	mob.position = mob_spawn_location.position

	# 设置怪物方向垂直于路径方向，并添加随机偏移
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# 设置随机速度
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)


## 分数计时器超时：增加分数并更新 UI。
func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)


## 开始计时器超时：启动怪物生成和分数计时器。
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
