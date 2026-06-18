## 大世界坐标演示 —— 控制面板，展示双精度浮点数在大坐标下的稳定性。
##
## 继承自 [VBoxContainer]，提供坐标增量按钮、相机控制、坐标显示等功能。
## 演示 Godot 在大坐标（±65536 以上）下使用双精度编译时的物理稳定性。
extends VBoxContainer

## 旋转速度
const ROT_SPEED = 0.003
## 缩放速度
const ZOOM_SPEED = 0.5
## 鼠标按钮掩码（左键 | 中键 | 右键）
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT

## 相机节点引用
@export var camera: Camera3D
## 相机旋转容器
@export var camera_holder: Node3D
## X 轴旋转节点
@export var rotation_x: Node3D
## 被移动的物体
@export var node_to_move: Node3D
## 刚体引用
@export var rigid_body: RigidBody3D

@onready var zoom := camera.position.z
@onready var rot_x := rotation_x.rotation.x
@onready var rot_y := camera_holder.rotation.y


## _ready 入口，检测双精度编译并显示提示。
func _ready() -> void:
	if OS.has_feature("double"):
		%HelpLabel.text = "Double precision is enabled in this engine build.\nNo shaking should occur at high coordinate levels\n(±65,536 or more on any axis)."
		%HelpLabel.add_theme_color_override(&"font_color", Color(0.667, 1, 0.667))


## _process 入口，每帧更新坐标显示和增量按钮逻辑。
func _process(delta: float) -> void:
	%Coordinates.text = "X: [color=#fb9]%f[/color]\nY: [color=#bfa]%f[/color]\nZ: [color=#9cf]%f[/color]" % [node_to_move.position.x, node_to_move.position.y, node_to_move.position.z]
	if %IncrementX.button_pressed:
		node_to_move.position.x += 10_000 * delta
	if %IncrementY.button_pressed:
		node_to_move.position.y += 100_000 * delta
	if %IncrementZ.button_pressed:
		node_to_move.position.z += 1_000_000 * delta


## _input 入口，处理鼠标滚轮缩放和拖拽旋转。
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= ZOOM_SPEED
		if input_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += ZOOM_SPEED
		zoom = clampf(zoom, 4, 15)
		camera.position.z = zoom

	if input_event is InputEventMouseMotion and input_event.button_mask & MAIN_BUTTONS:
		# 使用 screen_relative 使鼠标灵敏度不受视口分辨率影响
		var relative_motion: Vector2 = input_event.screen_relative
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clampf(rot_x, -1.4, 0.16)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))


## 跳转到指定 X 坐标位置。
func _on_go_to_button_pressed(x_position: int) -> void:
	if x_position == 0:
		# 重置所有坐标，不仅 X
		node_to_move.position = Vector3.ZERO
	else:
		node_to_move.position.x = x_position


## 打开大世界坐标文档。
func _on_open_documentation_pressed() -> void:
	OS.shell_open("https://docs.godotengine.org/en/latest/tutorials/physics/large_world_coordinates.html")
