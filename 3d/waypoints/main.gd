## 路径点演示场景的主节点。
##
## 继承自 [Node3D]，负责在兼容模式下调整光照设置。
## 在 gl_compatibility 渲染方法下，由于 sRGB 混合问题，需要额外创建一个仅用于照明的 DirectionalLight3D。
extends Node3D


## _ready 入口。检测渲染方法并调整光照参数。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 使用 PCF13 软阴影提高质量（Medium 模式下默认使用 PCF5）。
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$Sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $Sun.duplicate()
		new_light.light_energy = 0.35
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)
