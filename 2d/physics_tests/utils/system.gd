## 系统控制器 —— 管理全局设置和键盘快捷键。
extends Node

## 物理引擎枚举。
enum PhysicsEngine {
	GODOT_PHYSICS,  # Godot 内置物理
	OTHER,          # 其他物理引擎
}

var _engine: PhysicsEngine = PhysicsEngine.OTHER

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 启动时始终启用碰撞形状可视化
	get_tree().debug_collisions_hint = true

	var engine_string:= String(ProjectSettings.get_setting("physics/2d/physics_engine"))
	match engine_string:
		"DEFAULT":
			_engine = PhysicsEngine.GODOT_PHYSICS
		"GodotPhysics2D":
			_engine = PhysicsEngine.GODOT_PHYSICS
		_:
			_engine = PhysicsEngine.OTHER


func _process(_delta: float) -> void:
	# 全屏切换
	if Input.is_action_just_pressed(&"toggle_full_screen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# 调试碰撞切换
	if Input.is_action_just_pressed(&"toggle_debug_collision"):
		var debug_collision_enabled := not _is_debug_collision_enabled()
		_set_debug_collision_enabled(debug_collision_enabled)
		if debug_collision_enabled:
			Log.print_log("Debug Collision ON")
		else:
			Log.print_log("Debug Collision OFF")

	# 暂停切换
	if Input.is_action_just_pressed(&"toggle_pause"):
		get_tree().paused = not get_tree().paused

	# 退出
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()


## 获取当前物理引擎类型。
func get_physics_engine() -> PhysicsEngine:
	return _engine


func _set_debug_collision_enabled(enabled: bool) -> void:
	get_tree().debug_collisions_hint = enabled


func _is_debug_collision_enabled() -> bool:
	return get_tree().debug_collisions_hint
