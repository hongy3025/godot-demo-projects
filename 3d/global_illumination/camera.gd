## 自由飞行的 3D 摄像机控制器（全局光照演示版）。
##
## 继承自 [Camera3D]，支持鼠标拖拽旋转视角和 WASD 移动。
## 相比 waypoints 中的摄像机，增加了上下移动（Q/E 或类似按键）功能。
extends Camera3D


## 鼠标灵敏度系数。
const MOUSE_SENSITIVITY = 0.002
## 移动速度。
const MOVE_SPEED = 1.5

## 摄像机旋转欧拉角（弧度），x 为俯仰，y 为偏航。
var rot := Vector3()
## 摄像机移动速度向量，用于实现惯性效果。
var velocity := Vector3()

## _ready 入口。启动时捕获鼠标。
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## _input 入口。处理鼠标视角旋转和鼠标捕获切换。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	# 鼠标视角（仅在鼠标被捕获时生效）。
	if input_event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# 水平旋转（偏航）。
		rot.y -= input_event.screen_relative.x * MOUSE_SENSITIVITY
		# 垂直旋转（俯仰），限制在 -90 度到 90 度之间。
		rot.x = clamp(rot.x - input_event.screen_relative.y * MOUSE_SENSITIVITY, -1.57, 1.57)
		transform.basis = Basis.from_euler(rot)

	# 切换鼠标捕获状态。
	if input_event.is_action_pressed(&"toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## _process 入口。每帧处理键盘移动输入并更新位置。
##
## 参数:
##   delta: 帧时间间隔
##
## 核心逻辑：
## 1. 读取 WASD 输入向量（水平移动）
## 2. 读取上下移动输入（垂直移动）
## 3. 归一化防止对角线加速
## 4. 将输入向量从局部空间转换到世界空间
## 5. 应用阻尼（0.85）实现平滑移动
func _process(delta: float) -> void:
	var motion := Vector3(
			Input.get_axis(&"move_left", &"move_right"),
			0.0,
			Input.get_axis(&"move_forward", &"move_back")
		)
	var motion_y: float = Input.get_axis(&"move_down", &"move_up")

	# 归一化防止对角线移动速度比直线移动快 `sqrt(2)` 倍。
	motion = motion.normalized()

	velocity += MOVE_SPEED * delta * (transform.basis * motion)
	velocity += Vector3(0.0, MOVE_SPEED * delta * motion_y, 0.0)
	velocity *= 0.85
	position += velocity
