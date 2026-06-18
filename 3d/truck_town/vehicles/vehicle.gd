## 车辆控制器 —— 使用 VehicleBody3D 的汽车物理模拟。
##
## 继承自 [VehicleBody3D]，实现加速、刹车、转向、涡轮增压、
## 车灯控制、引擎音效和碰撞反馈。
extends VehicleBody3D

## 转向速度。
const STEER_SPEED = 1.5
## 最大转向角度。
const STEER_LIMIT = 0.4
## 刹车强度。
const BRAKE_STRENGTH = 2.0

## 引擎驱动力。
@export var engine_force_value := 40.0

## 涡轮表 Range 节点引用。
var turbometer: Range
## 涡轮动画播放器引用。
var turbo_animator: AnimationPlayer

## 上一帧速度。
var previous_speed := linear_velocity.length()
## 涡轮是否激活。
var turbo_active := false
## 车灯是否亮起。
var headlights_active := false
## 目标转向角度。
var _steer_target := 0.0
## 是否为兼容渲染模式。
var is_compatibility := RenderingServer.get_current_rendering_method() == "gl_compatibility"

## 目标引擎音调。
@onready var desired_engine_pitch: float = $EngineSound.pitch_scale


## _ready 入口。断言涡轮表和动画播放器已设置。
func _ready() -> void:
	assert(turbometer)
	assert(turbo_animator)


## _physics_process 入口。每物理帧处理车辆控制。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 读取转向输入
## 2. 模拟引擎音效（基于速度）
## 3. 检测碰撞并播放音效/震动
## 4. 处理涡轮增压
## 5. 处理加速/倒车
func _physics_process(delta: float) -> void:
	_steer_target = Input.get_axis(&"turn_right", &"turn_left")
	_steer_target *= STEER_LIMIT

	# 引擎音效模拟。
	desired_engine_pitch = 0.05 + linear_velocity.length() / (engine_force_value * 0.5)
	# 平滑改变音调，避免碰撞时突变。
	$EngineSound.pitch_scale = lerpf($EngineSound.pitch_scale, desired_engine_pitch, 0.2)

	if absf(linear_velocity.length() - previous_speed) > 1.0:
		# 速度突变，可能是碰撞。播放碰撞音效并震动。
		$ImpactSound.play()
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)

	var turbo_pressed := Input.is_action_pressed(&"boost")
	var new_turbo_active := turbo_pressed and turbometer.value > 0
	if new_turbo_active != turbo_active:
		turbo_animator.play(&"TURBO" if new_turbo_active else &"Idle")

	turbo_active = new_turbo_active
	if turbo_active:
		turbometer.value -= delta * 3.0
	elif not turbo_pressed:
		turbometer.value += delta

	if turbo_active:
		constant_force = global_transform.basis.z * 400.0
	else:
		constant_force = Vector3()

	# 触屏设备自动加速（倒车覆盖加速）。
	if DisplayServer.is_touchscreen_available() or Input.is_action_pressed(&"accelerate"):
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value

		if not DisplayServer.is_touchscreen_available():
			engine_force *= Input.get_action_strength(&"accelerate")
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"reverse"):
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value

		engine_force *= Input.get_action_strength(&"reverse")

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()


## _input 入口。处理车灯和喇叭输入。
##
## 参数:
##   p_input_event: 输入事件对象
func _input(p_input_event: InputEvent) -> void:
	if p_input_event.is_action_pressed(&"toggle_headlights"):
		toggle_headlights()

	if p_input_event.is_action_pressed(&"honk"):
		$HonkSound.play()


## 切换车灯开关。使用 Tween 实现平滑亮度过渡。
func toggle_headlights() -> void:
	for node: Light3D in get_tree().get_nodes_in_group(&"headlight"):
		headlights_active = is_zero_approx(node.light_energy)
		var t := get_tree().create_tween()

		if headlights_active:
			node.visible = true

		var target_energy := 2.0 if headlights_active else 0.0
		if is_compatibility:
			target_energy *= 0.5
		t.tween_property(
				node,
				^"light_energy",
				target_energy,
				0.2
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# 车灯关闭时隐藏节点以避免性能开销。
		if not headlights_active:
			t.finished.connect(func() -> void:
				node.visible = false
			)
