## 遮挡剔除和网格 LOD 演示场景的主控制器。
##
## 继承自 [Node3D]，提供遮挡剔除、网格 LOD、绘制模式和 V-Sync 的快捷键切换，
## 并实时显示渲染性能统计信息。
extends Node3D


## _input 入口。处理功能切换快捷键。
##
## 参数:
##   input_event: 输入事件对象
##
## 快捷键功能：
## - toggle_occlusion_culling: 切换遮挡剔除
## - toggle_mesh_lod: 切换网格 LOD
## - cycle_draw_mode: 循环切换绘制模式（正常/无光照/光照/过度绘制/线框）
## - toggle_vsync: 切换垂直同步
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_occlusion_culling"):
		get_viewport().use_occlusion_culling = not get_viewport().use_occlusion_culling
		update_labels()
	if input_event.is_action_pressed(&"toggle_mesh_lod"):
		get_viewport().mesh_lod_threshold = 1.0 if is_zero_approx(get_viewport().mesh_lod_threshold) else 0.0
		update_labels()
	if input_event.is_action_pressed(&"cycle_draw_mode"):
		get_viewport().debug_draw = wrapi(get_viewport().debug_draw + 1, 0, 5) as Viewport.DebugDraw
		update_labels()
	if input_event.is_action_pressed(&"toggle_vsync"):
		if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## _process 入口。每帧更新渲染性能统计信息。
##
## 显示内容：FPS、帧时间、渲染对象数、图元索引数（千）、绘制调用数。
func _process(_delta: float) -> void:
	$Performance.text = """%d FPS (%.2f mspf)

当前渲染:
%d 个对象
%dK 图元索引
%d 次绘制调用
""" % [
	Engine.get_frames_per_second(),
	1000.0 / Engine.get_frames_per_second(),
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
	roundi(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001),
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
]


## 更新所有状态标签的显示文本。
func update_labels() -> void:
	$OcclusionCulling.text = "遮挡剔除: %s" % ("已启用" if get_viewport().use_occlusion_culling else "已禁用")
	$MeshLOD.text = "网格 LOD: %s" % ("已启用" if not is_zero_approx(get_viewport().mesh_lod_threshold) else "已禁用")
	$DrawMode.text = "绘制模式: %s" % get_draw_mode_string(get_viewport().debug_draw)


## 获取绘制模式的显示字符串。
##
## 参数:
##   draw_mode: Viewport.DebugDraw 枚举值
##
## 返回: [String] 绘制模式的中文描述
func get_draw_mode_string(draw_mode: int) -> String:
	match draw_mode:
		0:
			return "正常"
		1:
			return "无光照"
		2:
			return "光照"
		3:
			return "过度绘制"
		4:
			return "线框"
		_:
			return "（未知）"
