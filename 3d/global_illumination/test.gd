## 全局光照（GI）演示场景的主控制器。
##
## 继承自 [Node3D]，提供多种全局光照模式的实时切换对比。
## 支持以下 GI 模式：无 GI、LightmapGI（全部/间接）、VoxelGI、SDFGI。
## 同时支持反射探针模式和屏幕空间光照（SSAO/SSIL）的切换。
extends Node3D

## 全局光照模式枚举。
enum GIMode {
	NONE,                ## 无全局光照，仅使用环境光。
	LIGHTMAP_GI_ALL,     ## LightmapGI 全部烘焙（直接+间接光照）。
	LIGHTMAP_GI_INDIRECT, ## LightmapGI 仅间接光照。
	VOXEL_GI,            ## VoxelGI 体素全局光照。
	SDFGI,               ## SDFGI 有符号距离场全局光照。
	MAX,                 ## 枚举最大值，内部使用。
}

## 反射探针模式枚举。
enum ReflectionProbeMode {
	NONE,   ## 禁用反射探针。
	ONCE,   ## 启用反射探针，更新模式为"一次"。
	ALWAYS, ## 启用反射探针，更新模式为"始终"。
	MAX,    ## 枚举最大值，内部使用。
}

## 屏幕空间光照模式枚举。
enum SSILMode {
	NONE,          ## 禁用屏幕空间光照效果。
	SSAO,          ## 仅屏幕空间环境光遮蔽。
	SSIL,          ## 仅屏幕空间间接光照。
	SSAO_AND_SSIL, ## 同时启用 SSAO 和 SSIL。
	MAX,           ## 枚举最大值，内部使用。
}

## SSIL 模式的显示文本（需与 SSILMode 枚举同步，MAX 除外）。
const SSIL_MODE_TEXTS = [
	"禁用（最快）",
	"屏幕空间环境光遮蔽（快）",
	"屏幕空间间接光照（中等）",
	"SSAO + SSIL（慢）",
]

## 反射探针模式的显示文本（需与 ReflectionProbeMode 枚举同步，MAX 除外）。
var reflection_probe_mode_texts: Array[String] = [
	"禁用 - 使用环境、VoxelGI 或 SDFGI 反射（快）",
	"启用 - \"一次\"更新模式（中等）",
	"启用 - \"始终\"更新模式（慢）",
]

## GI 模式的显示文本（需与 GIMode 枚举同步，MAX 除外）。
var gi_mode_texts: Array[String] = [
	"环境光照（最快）",
	"烘焙光照图全部（快）",
	"烘焙光照图间接（中等）",
	"VoxelGI（慢）",
	"SDFGI（慢）",
]

## 当前 GI 模式。
var gi_mode := GIMode.NONE
## 当前反射探针模式。
var reflection_probe_mode := ReflectionProbeMode.NONE
## 当前屏幕空间光照模式。
var ssil_mode := SSILMode.NONE
## 是否为兼容渲染模式。
var is_compatibility: bool = false

## 太阳光 DirectionalLight3D 引用。
## 在兼容模式下会被替换为新建的 DirectionalLight3D（不影响天空渲染）。
@onready var sun: DirectionalLight3D = $Sun
## LightmapGI 全部烘焙模式的光照数据。
@onready var lightmap_gi_all_data: LightmapGIData = $LightmapGIAll.light_data
## 环境资源引用。
@onready var environment: Environment = $WorldEnvironment.environment
## GI 模式显示标签。
@onready var gi_mode_label: Label = $GIMode
## FPS 显示标签。
@onready var fps: Label = $FPS
## 反射探针模式显示标签。
@onready var reflection_probe_mode_label: Label = $ReflectionProbeMode
## 反射探针节点引用。
@onready var reflection_probe: ReflectionProbe = $Camera/ReflectiveSphere/ReflectionProbe
## 屏幕空间光照模式显示标签。
@onready var ssil_mode_label: Label = $SSILMode

## 用于 LightmapGI 全部烘焙模式的场景副本。
@onready var zdm2_lightmap_all: Node3D = $Zdm2LightmapAll
## 用于 LightmapGI 间接烘焙模式的场景副本。
@onready var zdm2_lightmap_indirect: Node3D = $Zdm2LightmapIndirect


## _ready 入口。初始化 GI 模式、反射探针模式和 SSIL 模式。
func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		is_compatibility = true
		# 移除不支持的 VoxelGI/SDFGI 引用。
		reflection_probe_mode_texts[0] = "禁用 - 使用环境反射（快）"
		set_gi_mode(GIMode.NONE)
		# 降低光源能量以补偿 sRGB 混合（不影响天空渲染）。
		# 仅对启用了阴影的光源生效。
		$GrateOmniLight.light_energy = 0.25
		$GarageOmniLight.light_energy = 0.5
		sun.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		sun = sun.duplicate()
		sun.light_energy = 0.15
		sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(sun)
		$Help.text = """空格: 切换 GI 模式
R: 切换反射探针模式
Escape 或 F10: 切换鼠标捕获"""
	else:
		set_gi_mode(gi_mode)

	set_reflection_probe_mode(reflection_probe_mode)
	set_ssil_mode(ssil_mode)


## _input 入口。处理 GI 模式、反射探针模式和 SSIL 模式的切换快捷键。
##
## 参数:
##   input_event: 输入事件对象
##
## 支持 Shift 键反向切换。
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"cycle_gi_mode"):
		var incr: int = -1 if Input.is_key_pressed(KEY_SHIFT) else 1
		if is_compatibility:
			# 兼容模式下仅支持 LightmapGI。
			set_gi_mode(wrapi(gi_mode + incr, 0, GIMode.VOXEL_GI))
		else:
			set_gi_mode(wrapi(gi_mode + incr, 0, GIMode.MAX))

	if input_event.is_action_pressed(&"cycle_reflection_probe_mode"):
		var incr: int = -1 if Input.is_key_pressed(KEY_SHIFT) else 1
		set_reflection_probe_mode(wrapi(reflection_probe_mode + incr, 0, ReflectionProbeMode.MAX))

	if input_event.is_action_pressed(&"cycle_ssil_mode"):
		var incr: int = -1 if Input.is_key_pressed(KEY_SHIFT) else 1
		set_ssil_mode(wrapi(ssil_mode + incr, 0, SSILMode.MAX))


## _physics_process 入口。每物理帧更新 FPS 显示。
func _physics_process(_delta: float) -> void:
	fps.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]


## 设置全局光照模式。
##
## 参数:
##   p_gi_mode: 目标 GI 模式
##
## 根据选择的模式切换可见的场景副本、LightmapGI/VoxelGI/SDFGI 节点、
## 环境参数和光源烘焙模式。
func set_gi_mode(p_gi_mode: GIMode) -> void:
	gi_mode = p_gi_mode
	gi_mode_label.text = "全局光照: %s " % gi_mode_texts[gi_mode]

	match p_gi_mode:
		GIMode.NONE:
			if is_compatibility:
				# 兼容模式下隐藏 LightmapGI 节点时需清除 light_data 以避免 bug。
				$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			# 降低天空贡献度，防止阴影区域过亮过蓝。
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# 无 GI 时 Indirect 和 Disabled 没有区别，使用默认值 Indirect。
			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED

		GIMode.LIGHTMAP_GI_ALL:
			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false
			$LightmapGIAll.light_data = lightmap_gi_all_data

			# 降低天空贡献度（光照图模式下不影响光照图表面）。
			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = true
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			# 将光源烘焙模式设为 Static，使其不影响已烘焙表面。
			sun.light_bake_mode = Light3D.BAKE_STATIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_STATIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_STATIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC

		GIMode.LIGHTMAP_GI_INDIRECT:
			$LightmapGIAll.light_data = lightmap_gi_all_data
			$Zdm2LightmapAll.visible = false
			$Zdm2LightmapIndirect.visible = true

			environment.ambient_light_sky_contribution = 0.5
			$LightmapGIIndirect.visible = true
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = false

			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			# 标记盒子为动态对象，使其受益于光照图探针。
			# 在其他 GI 模式下不这样做，避免 VoxelGI 对动态对象的巨大性能开销。
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC

		GIMode.VOXEL_GI:
			# 清除 LightmapGIData 避免 VoxelGI 不可见的 bug。
			$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = true
			environment.sdfgi_enabled = false

			# 烘焙模式必须为 Indirect 而非 Disabled，否则这些光源的 GI 不可见。
			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED

		GIMode.SDFGI:
			# 清除 LightmapGIData 避免 SDFGI 不可见的 bug。
			$LightmapGIAll.light_data = null

			$Zdm2LightmapAll.visible = true
			$Zdm2LightmapIndirect.visible = false

			environment.ambient_light_sky_contribution = 1.0
			$LightmapGIIndirect.visible = false
			$LightmapGIAll.visible = false
			$VoxelGI.visible = false
			environment.sdfgi_enabled = true

			sun.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GrateOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$GarageOmniLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$CornerSpotLight.light_bake_mode = Light3D.BAKE_DYNAMIC
			$Camera/Box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED


## 设置反射探针模式。
##
## 参数:
##   p_reflection_probe_mode: 目标反射探针模式
func set_reflection_probe_mode(p_reflection_probe_mode: ReflectionProbeMode) -> void:
	reflection_probe_mode = p_reflection_probe_mode
	reflection_probe_mode_label.text = "反射探针: %s " % reflection_probe_mode_texts[reflection_probe_mode]

	match p_reflection_probe_mode:
		ReflectionProbeMode.NONE:
			reflection_probe.visible = false
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
		ReflectionProbeMode.ONCE:
			reflection_probe.visible = true
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE
		ReflectionProbeMode.ALWAYS:
			reflection_probe.visible = true
			reflection_probe.update_mode = ReflectionProbe.UPDATE_ALWAYS


## 设置屏幕空间光照模式。
##
## 参数:
##   p_ssil_mode: 目标 SSIL 模式
##
## 兼容模式下不支持屏幕空间光照效果。
func set_ssil_mode(p_ssil_mode: SSILMode) -> void:
	ssil_mode = p_ssil_mode
	if is_compatibility:
		ssil_mode_label.text = "屏幕空间光照效果: 兼容模式下不支持"
		ssil_mode_label.self_modulate.a = 0.6
		return
	else:
		ssil_mode_label.text = "屏幕空间光照效果: %s " % SSIL_MODE_TEXTS[ssil_mode]

	match p_ssil_mode:
		SSILMode.NONE:
			environment.ssao_enabled = false
			environment.ssil_enabled = false
		SSILMode.SSAO:
			environment.ssao_enabled = true
			environment.ssil_enabled = false
		SSILMode.SSIL:
			environment.ssao_enabled = false
			environment.ssil_enabled = true
		SSILMode.SSAO_AND_SSIL:
			environment.ssao_enabled = true
			environment.ssil_enabled = true
