## 动态分屏摄像机控制器 —— 控制两个玩家摄像机的运动以及与分屏 Shader 的通信。
##
## 继承自 [Node3D]，作为场景中控制分屏效果的核心逻辑节点。
## 摄像机放置在两个玩家连线的线段上：当玩家距离较近时，两台摄像机位于同一位置（不分屏）；
## 当玩家距离较远时，屏幕沿垂直于玩家连线的方向分割为两个视图。
##
## 可定制参数：
##   max_separation: 触发分屏的玩家最大间距
##   split_line_thickness: 分割线像素宽度
##   split_line_color: 分割线颜色
##   adaptive_split_line_thickness: 分割线宽度是否随玩家距离动态变化
extends Node3D

## 触发分屏的最大间距。玩家距离超过此值时屏幕开始分割。
@export var max_separation := 20.0
## 分割线的像素宽度。
@export var split_line_thickness := 3.0
## 分割线的颜色。
@export var split_line_color := Color.BLACK
## 是否启用自适应分割线宽度。为 true 时宽度随玩家距离变化，为 false 时固定为 split_line_thickness。
@export var adaptive_split_line_thickness: bool = true

## 玩家1的引用，通过节点路径获取。
@onready var player1: CharacterBody3D = $"../Player1"
## 玩家2的引用，通过节点路径获取。
@onready var player2: CharacterBody3D = $"../Player2"
## 用于显示最终分屏效果的 TextureRect 节点。
@onready var view: TextureRect = $View
## 玩家1的子视口，渲染玩家1的视角。
@onready var viewport1: SubViewport = $Viewport1
## 玩家2的子视口，渲染玩家2的视角。
@onready var viewport2: SubViewport = $Viewport2
## 玩家1的摄像机，位于 viewport1 下。
@onready var camera1: Camera3D = viewport1.get_node(^"Camera1")
## 玩家2的摄像机，位于 viewport2 下。
@onready var camera2: Camera3D = viewport2.get_node(^"Camera2")


## 初始化：更新视口大小并设置分屏参数。
## 连接窗口大小变化信号，将两个子视口的纹理传递给 Shader。
func _ready() -> void:
	_on_size_changed()
	_update_splitscreen()

	get_viewport().size_changed.connect(_on_size_changed)

	view.material.set_shader_parameter(&"viewport1", viewport1.get_texture())
	view.material.set_shader_parameter(&"viewport2", viewport2.get_texture())


## 每帧更新：移动摄像机位置并更新分屏参数。
func _process(_delta: float) -> void:
	_move_cameras()
	_update_splitscreen()


## 根据两个玩家的位置计算并移动两台摄像机。
## 核心逻辑：将摄像机放置在玩家连线的中点上，距离受 max_separation 限制。
## 当玩家距离小于 max_separation 时，两台摄像机位置重合（不分屏）；
## 当玩家距离大于 max_separation 时，两台摄像机分别向两侧偏移。
func _move_cameras() -> void:
	var position_difference := _get_position_difference_in_world()

	# 计算水平距离并限制在 max_separation 范围内
	var distance := clampf(_get_horizontal_length(position_difference), 0, max_separation)

	position_difference = position_difference.normalized() * distance

	# 摄像机1位于玩家1朝向玩家2方向的一半距离处
	camera1.position.x = player1.position.x + position_difference.x / 2.0
	camera1.position.z = player1.position.z + position_difference.z / 2.0

	# 摄像机2位于玩家2朝向玩家1方向的一半距离处
	camera2.position.x = player2.position.x - position_difference.x / 2.0
	camera2.position.z = player2.position.z - position_difference.z / 2.0


## 更新分屏 Shader 参数。
## 将两个玩家的屏幕坐标位置、分割线厚度、分割线颜色等参数传递给 Shader。
func _update_splitscreen() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	# 将玩家世界坐标转换为归一化的屏幕坐标（范围 0~1）
	var player1_position := camera1.unproject_position(player1.position) / screen_size
	var player2_position := camera2.unproject_position(player2.position) / screen_size

	var thickness := 0.0
	if adaptive_split_line_thickness:
		# 自适应分割线厚度：玩家距离越远，分割线越粗
		var position_difference := _get_position_difference_in_world()
		var distance := _get_horizontal_length(position_difference)
		thickness = lerpf(0, split_line_thickness, (distance - max_separation) / max_separation)
		thickness = clampf(thickness, 0, split_line_thickness)
	else:
		thickness = split_line_thickness

	view.material.set_shader_parameter(&"split_active", _is_split_state())
	view.material.set_shader_parameter(&"player1_position", player1_position)
	view.material.set_shader_parameter(&"player2_position", player2_position)
	view.material.set_shader_parameter(&"split_line_thickness", thickness)
	view.material.set_shader_parameter(&"split_line_color", split_line_color)


## 判断当前是否处于分屏状态。
## 当两个玩家的水平距离超过 max_separation 时返回 true，否则返回 false。
## 仅使用水平分量 (x, z) 计算距离。
func _is_split_state() -> bool:
	var position_difference := _get_position_difference_in_world()
	var separation_distance := _get_horizontal_length(position_difference)
	return separation_distance > max_separation


## 响应窗口大小变化：更新两个子视口的大小以匹配屏幕尺寸。
func _on_size_changed() -> void:
	var screen_size := get_viewport().get_visible_rect().size

	$Viewport1.size = screen_size
	$Viewport2.size = screen_size

	view.material.set_shader_parameter(&"viewport_size", screen_size)


## 计算两个玩家在世界空间中的位置差向量。
## 返回: [Vector3] player2.position - player1.position
func _get_position_difference_in_world() -> Vector3:
	return player2.position - player1.position


## 计算水平方向的距离（忽略 Y 轴）。
## 参数:
##   vec: 三维向量
## 返回: [float] 水平分量 (x, z) 的长度
func _get_horizontal_length(vec: Vector3) -> float:
	return Vector2(vec.x, vec.z).length()
