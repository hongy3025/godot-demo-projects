## 可见性范围（Visibility Ranges）演示场景的树簇管理器。
##
## 继承自 [Node3D]，生成大量树簇并管理其可见性范围和淡入淡出模式。
## 演示 Godot 的可见性范围功能：根据与摄像机的距离自动切换高/低细节模型。
extends Node3D

## 树簇数量。
const NUM_TREE_CLUSTERS = 2000
## 树簇分布范围。
const SPREAD = 1250
## 树簇场景预加载。
const TREE_CLUSTER_SCENE = preload("res://tree_cluster.tscn")

## 如果为 `false`，始终使用最高细节（性能更慢）。
var visibility_ranges_enabled = true

## `true` = 使用透明度淡入淡出，`false` = 使用迟滞（hysteresis）。
var fade_mode_enabled = true

## _ready 入口。生成树簇并等待加载完成。
func _ready():
	for i in 2:
		# 等待两帧让加载屏幕可见。
		await get_tree().process_frame

	# 使用预定义的随机种子以获得可重现的结果。
	seed(0x60d07)

	for i in NUM_TREE_CLUSTERS:
		var tree_cluster = TREE_CLUSTER_SCENE.instantiate()
		tree_cluster.position = Vector3(randf_range(-SPREAD, SPREAD), 0, randf_range(-SPREAD, SPREAD))
		add_child(tree_cluster)

	$Loading.visible = false


## _input 入口。处理可见性范围和淡入淡出模式的切换快捷键。
##
## 参数:
##   event: 输入事件对象
##
## toggle_visibility_ranges: 切换可见性范围
## toggle_fade_mode: 切换淡入淡出模式
func _input(event):
	if event.is_action_pressed(&"toggle_visibility_ranges"):
		visibility_ranges_enabled = not visibility_ranges_enabled
		$VisibilityRanges.text = "可见性范围: %s" % ("已启用" if visibility_ranges_enabled else "已禁用")
		$VisibilityRanges.modulate = Color.WHITE if visibility_ranges_enabled else Color.YELLOW
		$FadeMode.visible = visibility_ranges_enabled

		# 禁用可见性范围时，在任何距离都显示高细节树。
		for node in get_tree().get_nodes_in_group(&"tree_high_detail"):
			if visibility_ranges_enabled:
				node.visibility_range_begin = 0
				node.visibility_range_end = 20
			else:
				node.visibility_range_begin = 0
				node.visibility_range_end = 0
		for node in get_tree().get_nodes_in_group(&"tree_low_detail"):
			node.visible = visibility_ranges_enabled
		for node in get_tree().get_nodes_in_group(&"tree_cluster_high_detail"):
			node.visible = visibility_ranges_enabled
		for node in get_tree().get_nodes_in_group(&"tree_cluster_low_detail"):
			node.visible = visibility_ranges_enabled

	if event.is_action_pressed(&"toggle_fade_mode"):
		fade_mode_enabled = not fade_mode_enabled
		$FadeMode.text = "淡入淡出模式: %s" % ("已启用（透明度）" if fade_mode_enabled else "已禁用（迟滞）")

		for node in get_tree().get_nodes_in_group(&"tree_high_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED

		for node in get_tree().get_nodes_in_group(&"tree_low_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_end_margin = 50
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_end_margin = 0

		for node in get_tree().get_nodes_in_group(&"tree_cluster_high_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_begin_margin = 50
				node.visibility_range_end_margin = 50
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_begin_margin = 0
				node.visibility_range_end_margin = 0

		for node in get_tree().get_nodes_in_group(&"tree_cluster_low_detail"):
			if fade_mode_enabled:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
				node.visibility_range_end_margin = 100
			else:
				node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				node.visibility_range_end_margin = 0
