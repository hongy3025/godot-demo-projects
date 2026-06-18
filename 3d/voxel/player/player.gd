## 体素游戏玩家控制器 —— 第一人称体素世界角色。
##
## 继承自 [CharacterBody3D]，实现第一人称移动、跳跃、蹲伏、冲刺，
## 以及方块选择、放置、破坏和拾取功能。
extends CharacterBody3D

## 站立时眼睛高度。
const EYE_HEIGHT_STAND = 1.6
## 蹲伏时眼睛高度。
const EYE_HEIGHT_CROUCH = 1.4

## 地面移动速度。
const MOVEMENT_SPEED_GROUND = 70.0
## 空中移动速度。
const MOVEMENT_SPEED_AIR = 13.0
## 蹲伏速度修正系数。
const MOVEMENT_SPEED_CROUCH_MODIFIER = 0.5
## 冲刺速度修正系数。
const MOVEMENT_SPEED_SPRINT_MODIFIER = 1.375
## 地面摩擦力。
const MOVEMENT_FRICTION_GROUND = 12.5
## 空中摩擦力。
const MOVEMENT_FRICTION_AIR = 2.25
## 跳跃速度。
const MOVEMENT_JUMP_VELOCITY = 9.0

## 鼠标累积移动量。
var _mouse_motion := Vector2()
## 当前选中的方块 ID。
var _selected_block := 6

## 头部节点（控制俯仰）。
@onready var head: Node3D = $Head
## 摄像机节点。
@onready var camera: Camera3D = $Head/Camera3D
## 射线检测节点，用于方块交互。
@onready var raycast: RayCast3D = $Head/RayCast3D
## 摄像机属性（用于景深模糊）。
@onready var camera_attributes: CameraAttributes = $Head/Camera3D.attributes
## 选中方块纹理显示。
@onready var selected_block_texture: TextureRect = $SelectedBlock
## 体素世界引用。
@onready var voxel_world: VoxelWorld = $"../VoxelWorld"
## 准星节点。
@onready var crosshair: CenterContainer = $"../PauseMenu/Crosshair"
## 瞄准预览（半透明方块）。
@onready var aim_preview: MeshInstance3D = $AimPreview
## 默认 FOV。
@onready var neutral_fov: float = camera.fov


## _ready 入口。捕获鼠标。
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## _process 入口。处理鼠标视角、方块选择和交互。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 鼠标视角控制
## 2. 方块选择（滚轮/数字键/拾取）
## 3. 方块放置和破坏（射线检测 + 鼠标点击）
func _process(_delta: float) -> void:
	# 鼠标视角。
	_mouse_motion.y = clampf(_mouse_motion.y, -1560, 1560)
	transform.basis = Basis.from_euler(Vector3(0, _mouse_motion.x * -0.001, 0))
	head.transform.basis = Basis.from_euler(Vector3(_mouse_motion.y * -0.001, 0, 0))

	# 方块选择。
	var ray_position := raycast.get_collision_point()
	var ray_normal := raycast.get_collision_normal()
	if Input.is_action_just_pressed(&"pick_block"):
		# 拾取方块。
		var block_global_position: Vector3 = (ray_position - ray_normal / 2).floor()
		var block_sub_position: Vector3 = block_global_position.posmod(16)
		var chunk_position: Vector3 = (block_global_position - block_sub_position) / 16
		_selected_block = voxel_world.get_block_in_chunk(chunk_position, block_sub_position)
	else:
		# 前后切换方块。
		if Input.is_action_just_pressed(&"prev_block"):
			_selected_block -= 1
		if Input.is_action_just_pressed(&"next_block"):
			_selected_block += 1
		_selected_block = wrapi(_selected_block, 1, 30)
	# 设置选中方块纹理。
	var uv := Chunk.calculate_block_uvs(_selected_block)
	selected_block_texture.texture.region = Rect2(uv[0] * 512, Vector2.ONE * 64)

	# 方块破坏/放置。
	if crosshair.visible and raycast.is_colliding():
		aim_preview.visible = true
		var ray_current_block_position := Vector3i((ray_position - ray_normal / 2).floor())
		aim_preview.global_position = Vector3(ray_current_block_position) + Vector3(0.5, 0.5, 0.5)
		var breaking := Input.is_action_just_pressed(&"break")
		var placing := Input.is_action_just_pressed(&"place")
		# 同时按下或都没按则停止。
		if breaking == placing:
			return

		if breaking:
			var block_global_position := ray_current_block_position
			voxel_world.set_block_global_position(block_global_position, 0)
		elif placing:
			var block_global_position := Vector3i((ray_position + ray_normal / 2).floor())
			voxel_world.set_block_global_position(block_global_position, _selected_block)
	else:
		aim_preview.visible = false


## _physics_process 入口。每物理帧处理移动、跳跃、蹲伏和冲刺。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 根据雾效设置调整景深模糊
## 2. 处理蹲伏和冲刺
## 3. 读取 WASD 输入并应用移动
## 4. 应用重力和摩擦力
## 5. 处理跳跃
func _physics_process(delta: float) -> void:
	camera_attributes.dof_blur_far_enabled = Settings.fog_enabled
	camera_attributes.dof_blur_far_distance = Settings.fog_distance * 1.5
	camera_attributes.dof_blur_far_transition = Settings.fog_distance * 0.125
	# 蹲伏。
	var crouching: bool = Input.is_action_pressed(&"crouch")
	var sprinting: bool = Input.is_action_pressed(&"move_sprint")
	head.transform.origin.y = lerpf(head.transform.origin.y, EYE_HEIGHT_CROUCH if crouching else EYE_HEIGHT_STAND, 1.0 - exp(-delta * 16.0))

	# 键盘移动。
	var movement_vec2: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var movement: Vector3 = transform.basis * (Vector3(movement_vec2.x, 0, movement_vec2.y))

	if is_on_floor():
		movement *= MOVEMENT_SPEED_GROUND
	else:
		movement *= MOVEMENT_SPEED_AIR

	if crouching:
		movement *= MOVEMENT_SPEED_CROUCH_MODIFIER
		sprinting = false
	var target_fov: float = neutral_fov
	if sprinting:
		movement *= MOVEMENT_SPEED_SPRINT_MODIFIER
		target_fov = neutral_fov * 1.25
	camera.fov = lerpf(camera.fov, target_fov, 1.0 - exp(-delta * 10.0))

	# 重力。
	if not is_on_floor():
		var factor: float = 3.0 - clampf(velocity.y / -MOVEMENT_JUMP_VELOCITY, 0.0, 2.0)
		velocity += get_gravity() * (delta * factor)

	velocity += Vector3(movement.x, 0, movement.z) * delta
	# 应用水平摩擦力。
	var friction_delta := exp(-(MOVEMENT_FRICTION_GROUND if is_on_floor() else MOVEMENT_FRICTION_AIR) * delta)
	velocity = Vector3(velocity.x * friction_delta, velocity.y, velocity.z * friction_delta)
	move_and_slide()

	# 跳跃（下一帧应用）。
	if is_on_floor() and Input.is_action_pressed(&"jump"):
		velocity.y = MOVEMENT_JUMP_VELOCITY


## _input 入口。累积鼠标移动量。
##
## 参数:
##   input_event: 输入事件对象
func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_mouse_motion += input_event.screen_relative


## 获取玩家当前所在的区块位置。
##
## 返回: [Vector3i] 区块坐标
func chunk_pos() -> Vector3i:
	return Vector3i((transform.origin / Chunk.CHUNK_SIZE).floor())
