## 平台游戏关卡场景控制器。
##
## 继承自 [Node3D]，在兼容模式下调整光照设置。
extends Node3D


## _ready 入口。检测渲染方法并调整光照参数。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 使用 PCF13 软阴影提高质量（Medium 模式下默认使用 PCF5）。
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $DirectionalLight3D.duplicate()
		new_light.light_energy = 0.25
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)
