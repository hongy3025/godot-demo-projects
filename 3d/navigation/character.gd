## 导航角色控制器 —— 使用 NavigationAgent3D 实现自动寻路。
##
## 继承自 [Marker3D]，通过 NavigationAgent3D 获取路径并沿路径移动。
## 支持显示导航路径线（Line3D）和面向移动方向。
extends Marker3D

## 角色移动速度。
@export var character_speed := 10.0
## 是否显示导航路径。
@export var show_path: bool = true

## 导航路径线绘制工具实例。
var _nav_path_line: Line3D

## NavigationAgent3D 节点引用，用于路径查询和导航。
@onready var _nav_agent := $NavigationAgent3D as NavigationAgent3D

## _ready 入口。创建路径线绘制工具并添加到场景。
func _ready() -> void:
	_nav_path_line = Line3D.new()
	add_child(_nav_path_line)
	# 设置为顶层模式，使路径线在世界空间中独立定位。
	_nav_path_line.set_as_top_level(true)


## _physics_process 入口。每物理帧沿导航路径移动角色。
##
## 参数:
##   delta: 物理帧时间间隔
##
## 核心逻辑：
## 1. 检查导航是否完成
## 2. 获取下一个路径位置
## 3. 向目标位置移动
## 4. 面向移动方向（仅水平旋转）
func _physics_process(delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return

	var next_position := _nav_agent.get_next_path_position()
	var offset := next_position - global_position
	global_position = global_position.move_toward(next_position, delta * character_speed)

	# 让角色面向移动方向。
	# 将 Y 轴置零，使角色仅左右旋转，不上下倾斜。
	offset.y = 0
	if not offset.is_zero_approx():
		look_at(global_position + offset, Vector3.UP)


## 设置目标位置并触发导航。
##
## 参数:
##   target_position: 目标世界坐标
##
## 如果启用了路径显示，通过 NavigationServer3D API 获取完整路径并绘制。
func set_target_position(target_position: Vector3) -> void:
	_nav_agent.set_target_position(target_position)
	# 通过 NavigationServer3D API 获取完整导航路径。
	if show_path:
		var start_position := global_transform.origin
		var optimize: bool = true
		var navigation_map := get_world_3d().get_navigation_map()
		var path := NavigationServer3D.map_get_path(
				navigation_map,
				start_position,
				target_position,
				optimize
			)
		_nav_path_line.draw_path(path)
