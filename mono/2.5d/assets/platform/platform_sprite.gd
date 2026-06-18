## 2.5D 平台精灵 —— 根据当前视角模式切换对应的平台纹理。
##
## 继承自 [Sprite2D]，是一个 2D 精灵节点。
## 预加载了 6 种视角模式对应的平台纹理，根据视角切换按键动态切换纹理。
## @tool 注解使其在编辑器中也能运行。
@tool
extends Sprite2D

## 45 度视角的平台纹理
## @onready 确保在节点就绪后加载资源
@onready var _forty_five = preload("res://assets/platform/textures/forty_five.png")
## 等距视角的平台纹理
@onready var _isometric = preload("res://assets/platform/textures/isometric.png")
## 俯视视角的平台纹理
@onready var _top_down = preload("res://assets/platform/textures/top_down.png")
## 正面视角的平台纹理
@onready var _front_side = preload("res://assets/platform/textures/front_side.png")
## 斜 Y 视角的平台纹理
@onready var _oblique_y = preload("res://assets/platform/textures/oblique_y.png")
## 斜 Z 视角的平台纹理
@onready var _oblique_z = preload("res://assets/platform/textures/oblique_z.png")


## _process 每帧调用，检测视角切换按键并更新平台纹理。
##
## 功能：
##   监听 6 种视角模式按键（forty_five_mode 等），
##   按下时调用 set_view_mode 切换纹理。
##   使用 Engine.is_editor_hint() 判断是否在编辑器中运行，
##   在编辑器中不处理输入，避免干扰编辑器操作。
##
## 参数：
##   _delta: 帧时间差（秒），此处未使用
func _process(_delta):
	# 仅在非编辑器模式下处理按键输入
	if not Engine.is_editor_hint():
		# 检测各个视角模式按键（使用 is_action_pressed 持续检测）
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


## 根据视角模式索引切换平台纹理。
##
## 功能：
##   根据传入的视角模式索引，将当前 Sprite2D 的 texture 属性
##   切换到对应的预加载纹理。
##
## 参数：
##   view_mode_index: 视角模式索引 (0-5)
##     0 - 45 度 (Forty Five)
##     1 - 等距 (Isometric)
##     2 - 俯视 (Top Down)
##     3 - 正面 (Front Side)
##     4 - 斜 Y (Oblique Y)
##     5 - 斜 Z (Oblique Z)
func set_view_mode(view_mode_index):
	# 使用 match 语句根据索引选择对应的平台纹理
	match view_mode_index:
		0: # 45 度视角
			texture = _forty_five;
		1: # 等距视角
			texture = _isometric
		2: # 俯视视角
			texture = _top_down
		3: # 正面视角
			texture = _front_side
		4: # 斜 Y 视角
			texture = _oblique_y
		5: # 斜 Z 视角
			texture = _oblique_z
