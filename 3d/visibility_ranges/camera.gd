## 自由飞行的 3D 摄像机控制器（可见性范围演示版）。
##
## 继承自 [Camera3D]，支持鼠标拖拽旋转视角和 WASD 移动。
extends Camera3D

## 鼠标灵敏度系数。
const MOUSE_SENSITIVITY = 0.002
## 移动速度（较快，适合大场景浏览）。
const MOVE_SPEED = 10.0

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
##
## 注意：加载屏幕结束后（帧数 > 2）才启用鼠标视角，防止加载时的误操作。
func _input(input_event: InputEvent) -> void:
	# 鼠标视角（仅在鼠标被捕获且加载完成后生效）。
	if input_event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and Engine.get_process_frames() > 2:
		# 水平旋转（偏航）。
		rot.y -= input_event.relative.x * MOUSE_SENSITIVITY
		# 垂直旋转（俯仰），限制在 -90 度到 90 度之间。
		rot.x = clampf(rot.x - input_event.relative.y * MOUSE_SENSITIVITY, -1.57, 1.57)
		transform.basis = Basis.from_euler(rot)

	if input_event.is_action_pressed(&"toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## _process 入口。每帧处理键盘移动输入并更新位置。
##
## 参数:
##   delta: 帧时间间隔
func _process(delta: float) -> void:
	var motion := Vector3(
			Input.get_axis(&"move_left", &"move_right"),
			0,
			Input.get_axis(&"move_forward", &"move_back")
		)

	# 归一化防止对角线移动速度比直线移动快 `sqrt(2)` 倍。
	motion = motion.normalized()

	velocity += MOVE_SPEED * delta * (transform.basis * motion)
	velocity *= 0.85
	position += velocity
