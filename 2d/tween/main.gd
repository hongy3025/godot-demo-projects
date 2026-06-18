## Tween 动画演示主控制器。
## 继承自 Node，演示 Godot Tween 系统的各种用法：
## 属性动画、方法动画、并行/串行动画、子 Tween、循环、回调等。
extends Node

## 主 Tween 对象，控制图标的所有动画序列。
var tween: Tween
## 子 Tween 对象，用于并行执行独立的动画子序列。
var sub_tween: Tween

## 图标精灵节点，通过 % 唯一名称引用。
@onready var icon: Sprite2D = %Icon
## 缓存图标的初始位置，用于重置动画。
@onready var icon_start_position := icon.position

## 倒计时标签。
@onready var countdown_label: Label = %CountdownLabel
## 路径节点，用于曲线路径动画。
@onready var path: Path2D = $Path2D
## 进度条，显示动画播放进度。
@onready var progress: TextureProgressBar = %Progress

## 每帧更新进度条，显示当前动画已播放时间。
func _process(_delta: float) -> void:
	if not tween or not tween.is_running():
		return

	progress.value = tween.get_total_elapsed_time()


## 启动完整动画序列。
## 包含 10 个步骤：移动、变色、滚动、跳跃、闪烁、传送、曲线路径、等待、倒计时、放大消失。
## 每个步骤可通过 UI 开关独立启用/禁用。
func start_animation() -> void:
	# 重置图标到初始状态
	reset()
	# 创建 Tween，同时设置初始动画速度。
	# 所有修改 Tween 的方法都会返回 Tween 自身，因此可以链式调用。
	tween = create_tween().set_speed_scale(%SpeedSlider.value)

	# 设置循环次数。1 次循环 = 1 个动画周期。
	# 例如 2 次循环将播放两遍动画。
	if %Infinite.button_pressed:
		tween.set_loops() # 无参数调用时无限循环
	else:
		tween.set_loops(%Loops.value)

	# 步骤 1：移动到指定位置

	if is_step_enabled("MoveTo", 1.0):
		# tween_*() 方法返回 Tweener 对象，其方法也可链式调用。
		# 此处用变量存储以提高可读性。
		# 注意使用 ^"NodePath"（字符串节点路径的优化版本）。
		var tweener := tween.tween_property(icon, ^"position", Vector2(400, 250), 1.0)
		tweener.set_ease(%Ease1.selected)
		tweener.set_trans(%Trans1.selected)

	# 步骤 2：颜色变为红色

	if is_step_enabled("ColorRed", 1.0):
		tween.tween_property(icon, ^"self_modulate", Color.RED, 1.0)

	# 步骤 3：向右移动 + 旋转

	if is_step_enabled("MoveRight", 1.0):
		# as_relative() 使值为相对值，此处表示从当前位置向右移动 200 像素
		var tweener := tween.tween_property(icon, ^"position:x", 200.0, 1.0).as_relative()
		tweener.set_ease(%Ease3.selected)
		tweener.set_trans(%Trans3.selected)
	if is_step_enabled("Roll", 0.0):
		# parallel() 使 Tweener 与上一个动画并行执行
		var tweener := tween.parallel().tween_property(icon, ^"rotation", TAU, 1.0)
		tweener.set_ease(%Ease3.selected)
		tweener.set_trans(%Trans3.selected)

	# 步骤 4：向左移动 + 跳跃

	if is_step_enabled("MoveLeft", 1.0):
		tween.tween_property(icon, ^"position", Vector2.LEFT * 200, 1.0).as_relative()
	if is_step_enabled("Jump", 0.0):
		# 跳跃包含 2 个子步骤，使用子 Tween 实现并行效果。
		# 通过 tween_callback 调用 lambda 创建子 Tween。
		# 多个 Tween 可以同时动画同一个对象。
		tween.parallel().tween_callback(func():
				# 注意：transition 设置在 Tween 上，ease 设置在 Tweener 上。
				# Tween 上的设置会作为所有 Tweener 的默认值，Tweener 上的设置可覆盖。
				sub_tween = create_tween().set_speed_scale(%SpeedSlider.value).set_trans(Tween.TRANS_SINE)
				sub_tween.tween_property(icon, ^"position:y", -150.0, 0.5).as_relative().set_ease(Tween.EASE_OUT)
				sub_tween.tween_property(icon, ^"position:y", 150.0, 0.5).as_relative().set_ease(Tween.EASE_IN)
			)

	# 步骤 5：闪烁效果

	if is_step_enabled("Blink", 2.0):
		# 循环适合创建重复动画效果
		for i in 10:
			tween.tween_callback(icon.hide).set_delay(0.1)
			tween.tween_callback(icon.show).set_delay(0.1)

	# 步骤 6：传送效果

	if is_step_enabled("Teleport", 0.5):
		# 持续时间为 0 的动画会立即改变值
		tween.tween_property(icon, ^"position", Vector2(325, 325), 0)
		tween.tween_interval(0.5)
		# bind 可用于高级回调，预先绑定参数
		tween.tween_callback(icon.set_position.bind(Vector2(680, 215)))

	# 步骤 7：沿曲线路径移动

	if is_step_enabled("Curve", 3.5):
		# 方法动画适合动画化无法直接插值的值。
		# 可用于重映射和高级动画。
		# 此处用于沿路径移动精灵，使用内联 lambda 函数。
		var tweener := tween.tween_method(
				func(v: float) -> void:
					icon.position = path.position + path.curve.sample_baked(v), 0.0, path.curve.get_baked_length(), 3.0
			).set_delay(0.5)
		tweener.set_ease(%Ease7.selected)
		tweener.set_trans(%Trans7.selected)

	# 步骤 8：等待间隔

	if is_step_enabled("Wait", 2.0):
		tween.tween_interval(2)

	# 步骤 9：倒计时

	if is_step_enabled("Countdown", 3.0):
		tween.tween_callback(countdown_label.show)
		tween.tween_method(do_countdown, 4, 1, 3)
		tween.tween_callback(countdown_label.hide)

	# 步骤 10：放大 + 消失

	if is_step_enabled("Enlarge", 0.0):
		tween.tween_property(icon, ^"scale", Vector2.ONE * 5, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if is_step_enabled("Vanish", 1.0):
		tween.parallel().tween_property(icon, ^"self_modulate:a", 0.0, 1.0)

	# 循环结束时重置图标显示
	if %Loops.value > 1 or %Infinite.button_pressed:
		tween.tween_callback(icon.show)
		tween.tween_callback(icon.set_self_modulate.bind(Color.WHITE))

	# 重置步骤：动画结束后重置状态

	if %Reset.button_pressed:
		tween.tween_callback(reset.bind(true))


## 倒计时回调函数，更新标签文本。
## 参数 number: 当前倒计时的数字。
func do_countdown(number: int) -> void:
	countdown_label.text = str(number)


## 重置图标到初始状态。
## 参数 soft: 如果为 true，仅重置属性不销毁 Tween 对象。
func reset(soft: bool = false) -> void:
	icon.position = icon_start_position
	icon.self_modulate = Color.WHITE
	icon.rotation = 0
	icon.scale = Vector2.ONE
	icon.show()
	countdown_label.hide()

	if soft:
		# 仅重置属性，不销毁 Tween
		return

	if tween:
		tween.kill()
		tween = null

	if sub_tween:
		sub_tween.kill()
		sub_tween = null

	progress.max_value = 0


## 检查步骤是否启用，并累加进度条最大值。
## 参数 step: UI 中复选框的名称。
## 参数 expected_time: 该步骤预计耗时。
## 返回: bool，该步骤是否启用。
func is_step_enabled(step: String, expected_time: float) -> bool:
	var enabled: bool = get_node("%" + step).button_pressed
	if enabled:
		progress.max_value += expected_time

	return enabled


## 暂停/恢复动画播放。
func pause_resume() -> void:
	if tween and tween.is_valid():
		if tween.is_running():
			tween.pause()
		else:
			tween.play()

	if sub_tween and sub_tween.is_valid():
		if sub_tween.is_running():
			sub_tween.pause()
		else:
			sub_tween.play()


## 销毁所有 Tween 对象，停止动画。
func kill_tween() -> void:
	if tween:
		tween.kill()
	if sub_tween:
		sub_tween.kill()


## 动画速度变化时的回调。
## 参数 value: 新的速度倍率。
func speed_changed(value: float) -> void:
	if tween:
		tween.set_speed_scale(value)
	if sub_tween:
		sub_tween.set_speed_scale(value)

	%SpeedLabel.text = str("x", value)


## 无限循环切换回调。
## 参数 button_pressed: 是否开启无限循环。
func infinite_toggled(button_pressed: bool) -> void:
	%Loops.editable = not button_pressed
