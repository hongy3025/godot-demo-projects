## 卡车小镇场景控制器 —— 管理天气氛围、灯光和音效。
##
## 继承自 [Node3D]，支持四种氛围模式（日出/白天/日落/夜晚）的切换，
## 自动控制车灯、环境音效和兼容模式光照适配。
extends Node3D

## 氛围模式枚举。
enum Mood {
	SUNRISE,  ## 日出。
	DAY,      ## 白天。
	SUNSET,   ## 日落。
	NIGHT,    ## 夜晚。
}

## 操作说明面板。
@onready var controls_sheet: Control = %Controls

## 当前氛围模式。
var mood := Mood.DAY: set = set_mood

## 是否开启灯光。
var turn_on_lights: bool = false
## 各氛围模式对应的环境音效资源。
var ambient_sound: Array = [
	preload("res://town/sound/mood_sunrise.ogg"),
	preload("res://town/sound/mood_day.ogg"),
	preload("res://town/sound/mood_sunset.ogg"),
	preload("res://town/sound/mood_night.ogg"),
]

# 仅在兼容渲染模式下使用。
# 用于降低阳光亮度以补偿 sRGB 混合（不影响天空渲染）。
var compatibility_light: DirectionalLight3D


## 设置场景。将车辆添加到场景并配置引用。
##
## 参数:
##   car: 车辆节点
##   back_callback: 返回按钮回调
##   sdfgi: 是否启用 SDFGI
func setup(car: Node3D, back_callback: Callable, sdfgi: bool) -> void:
	var car_body: VehicleBody3D = car.get_child(0)

	car_body.turbometer = %Turbometer
	car_body.turbo_animator = %TurboAnimator
	%Speedometer.car_body = car_body
	%InstancePos.add_child(car)

	%Back.pressed.connect(back_callback)
	%WorldEnvironment.environment.sdfgi_enabled = sdfgi


## _ready 入口。初始化氛围、操作面板和兼容模式适配。
func _ready() -> void:
	# 确保车灯根据初始氛围自动开关。
	set_deferred(&"mood", mood)
	controls_sheet.hide()

	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# 使用 PCF13 软阴影提高质量。
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# 降低光源能量以补偿 sRGB 混合。
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		compatibility_light = $DirectionalLight3D.duplicate()
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2
		compatibility_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(compatibility_light)

		for headlight: Light3D in get_tree().get_nodes_in_group(&"headlight"):
			# 启用反向面剔除以修复兼容模式下的阴影偏差。
			headlight.shadow_reverse_cull_face = true


## _input 入口。处理氛围切换和操作面板显示。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"cycle_mood"):
		mood = wrapi(mood + 1, 0, Mood.size()) as Mood
		$AmbientSound.play()
		for l: Node3D in $Lamps.get_children():
			l.get_node("Light").visible = turn_on_lights
	elif input_event.is_action_pressed(&"toggle_controls"):
		controls_sheet.visible = not controls_sheet.visible


## 设置氛围模式。更新光照、天空、雾效和车灯。
##
## 参数:
##   p_mood: 目标氛围模式
func set_mood(p_mood: Mood) -> void:
	mood = p_mood
	turn_on_lights = false

	match p_mood:
		Mood.SUNRISE:
			$DirectionalLight3D.rotation_degrees = Vector3(-20, -150, -137)
			$DirectionalLight3D.light_color = Color(0.414, 0.377, 0.25)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_morning.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.686, 0.6, 0.467)
		Mood.DAY:
			$DirectionalLight3D.rotation_degrees = Vector3(-55, -120, -31)
			$DirectionalLight3D.light_color = Color.WHITE
			$DirectionalLight3D.light_energy = 1.45
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_day.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.725, 0.918, 1.0)
		Mood.SUNSET:
			$DirectionalLight3D.rotation_degrees = Vector3(-19, -31, 62)
			$DirectionalLight3D.light_color = Color(0.488, 0.3, 0.1)
			$DirectionalLight3D.light_energy = 4.0
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_sunset.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.776, 0.549, 0.502)
			turn_on_lights = true
		Mood.NIGHT:
			$DirectionalLight3D.rotation_degrees = Vector3(-49, 116, -46)
			$DirectionalLight3D.light_color = Color(0.232, 0.415, 0.413)
			$DirectionalLight3D.light_energy = 0.7
			$WorldEnvironment.environment.sky.sky_material = preload("res://town/sky_night.tres")
			$WorldEnvironment.environment.fog_light_color = Color(0.2, 0.149, 0.125)
			turn_on_lights = true

	$AmbientSound.stream = ambient_sound[p_mood]

	if compatibility_light:
		compatibility_light.rotation_degrees = $DirectionalLight3D.rotation_degrees
		compatibility_light.light_color = $DirectionalLight3D.light_color
		compatibility_light.light_energy = $DirectionalLight3D.light_energy * 0.2

	if is_inside_tree():
		var car := get_tree().get_nodes_in_group(&"car")[0]
		if (
				turn_on_lights and not car.headlights_active
		) or (
				not turn_on_lights and car.headlights_active
		):
			get_tree().call_group(&"car", &"toggle_headlights")
