## "踩怪"（Squash the Creeps）游戏主场景控制器。
##
## 继承自 [Node]，管理怪物的定时生成、玩家碰撞处理和游戏重试。
extends Node

## 怪物场景预加载。
@export var mob_scene: PackedScene


## _ready 入口。初始化兼容模式适配并隐藏重试按钮。
func _ready():
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 使用 PCF13 软阴影提高质量（Medium 模式下默认使用 PCF5）。
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $DirectionalLight3D.duplicate()
		new_light.light_energy = 0.35
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)


	$UserInterface/Retry.hide()


## _unhandled_input 入口。处理重试输入。
##
## 参数:
##   event: 输入事件对象
##
## 当重试按钮可见时，按确认键重新加载当前场景。
func _unhandled_input(event):
	if event.is_action_pressed(&"ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()


## 怪物生成定时器超时回调。在随机位置生成怪物。
func _on_mob_timer_timeout():
	# 创建怪物实例。
	var mob = mob_scene.instantiate()

	# 在 SpawnPath 上选择随机位置。
	var mob_spawn_location = get_node(^"SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# 将生成位置和玩家位置传递给怪物。
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# 将怪物添加到场景。
	add_child(mob)
	# 连接怪物的 squashed 信号到分数标签。
	mob.squashed.connect($UserInterface/ScoreLabel._on_Mob_squashed)


## 玩家被击中回调。停止怪物生成并显示重试按钮。
func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
