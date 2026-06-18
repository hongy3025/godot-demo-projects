## 玩家精灵渲染 —— 处理 8 方向动画和视角适配。
##
## 继承自 [Sprite2D]，作为 Node25D 的子节点存在。
## 根据玩家移动方向选择对应的精灵帧，支持站立/跑步/跳跃三种动画状态。
## 根据当前视角模式调整 Sprite 的 transform，使精灵在不同视角下保持正确朝向。
@tool
extends Sprite2D


## 动画播放速率（帧/秒）
const ANIMATION_FRAMERATE = 15

## 当前朝向 (0-7，8 方向)
var _direction: int = 0
## 动画进度 (0.0 ~ 6.0，用于帧循环)
var _progress: float = 0.0
var _parent_node25d: Node25D
var _parent_math: PlayerMath25D

@onready var _stand: Texture2D = preload("res://assets/player/textures/stand.png")
@onready var _jump: Texture2D = preload("res://assets/player/textures/jump.png")
@onready var _run: Texture2D = preload("res://assets/player/textures/run.png")


func _ready() -> void:
	_parent_node25d = get_parent()
	_parent_math = _parent_node25d.get_child(0)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return  # 编辑器中不执行动画逻辑

	_sprite_basis()
	var movement := _check_movement()

	# 使用 move_and_collide 检测是否在地面上（仅检测，不实际移动）
	var k := _parent_math.move_and_collide(Vector3.DOWN * 10 * delta, true, true, true)
	if k != null:
		# 在地面上
		if movement:
			# 跑步动画: 6 帧循环
			hframes = 6
			texture = _run
			if Input.is_action_pressed(&"movement_modifier"):
				delta /= 2
			_progress = fmod((_progress + ANIMATION_FRAMERATE * delta), 6)
			frame = _direction * 6 + int(_progress)
		else:
			# 站立动画: 单帧
			hframes = 1
			texture = _stand
			_progress = 0
			frame = _direction
	else:
		# 在空中（跳跃/下落）
		hframes = 2
		texture = _jump
		_progress = 0
		var jumping := 1 if _parent_math.vertical_speed < 0 else 0
		frame = _direction * 2 + jumping


## 根据视角模式调整 Sprite 的 2D 变换，使精灵在不同视角下保持正确外观。
func set_view_mode(view_mode_index: int) -> void:
	match view_mode_index:
		0:  # 45 度 —— 垂直方向压缩 75%
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 0.75)
		1:  # 等距 —— 保持原始比例
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 1)
		2:  # 俯视 —— 垂直方向压缩 50%
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 0.5)
		3:  # 正面 —— 保持原始比例
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0, 1)
		4:  # 斜 Y —— 倾斜变换
			transform.x = Vector2(1, 0)
			transform.y = Vector2(0.75, 0.75)
		5:  # 斜 Z —— 倾斜变换
			transform.x = Vector2(1, 0.25)
			transform.y = Vector2(0, 1)


## 检测视角切换按键并更新 Sprite 变换。
func _sprite_basis() -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_pressed(&"forty_five_mode"):
			set_view_mode(0)
		elif Input.is_action_pressed(&"isometric_mode"):
			set_view_mode(1)
		elif Input.is_action_pressed(&"top_down_mode"):
			set_view_mode(2)
		elif Input.is_action_pressed(&"front_side_mode"):
			set_view_mode(3)
		elif Input.is_action_pressed(&"oblique_y_mode"):
			set_view_mode(4)
		elif Input.is_action_pressed(&"oblique_z_mode"):
			set_view_mode(5)


## 检测玩家输入并计算 8 方向朝向。
## 返回: 是否有移动输入
##
## 方向映射:
##   0=下, 1=左下, 2=左/右, 3=左上, 4=上
##   左右方向通过 flip_h 实现镜像
func _check_movement() -> bool:
	var x := 0
	var z := 0

	if Input.is_action_pressed(&"move_right"):
		x += 1
	if Input.is_action_pressed(&"move_left"):
		x -= 1
	if Input.is_action_pressed(&"move_forward"):
		z -= 1
	if Input.is_action_pressed(&"move_back"):
		z += 1

	# 非等距控制模式下，在等距视角中自动修正方向映射
	if not _parent_math.isometric_controls and is_equal_approx(Node25D.SCALE * 0.86602540378, _parent_node25d.get_basis()[0].x):
		if Input.is_action_pressed(&"move_right"):
			z += 1
		if Input.is_action_pressed(&"move_left"):
			z -= 1
		if Input.is_action_pressed(&"move_forward"):
			x += 1
		if Input.is_action_pressed(&"move_back"):
			x -= 1

	# 根据 X/Z 输入确定 8 方向
	if x == 0:
		if z == 0:
			return false  # 无输入
		elif z > 0:
			_direction = 0
		else:
			_direction = 4
	elif x > 0:
		if z == 0:
			_direction = 2
			flip_h = true
		elif z > 0:
			_direction = 1
			flip_h = true
		else:
			_direction = 3
			flip_h = true
	else:
		if z == 0:
			_direction = 2
			flip_h = false
		elif z > 0:
			_direction = 1
			flip_h = false
		else:
			_direction = 3
			flip_h = false

	return true  # 有移动输入
