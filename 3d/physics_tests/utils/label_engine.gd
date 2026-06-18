## 物理引擎名称显示标签。
extends Label


func _ready() -> void:
	var engine_name: String = ""
	match System.get_physics_engine():
		System.PhysicsEngine.GODOT_PHYSICS:
			engine_name = "GodotPhysics 3D"
		System.PhysicsEngine.JOLT_PHYSICS:
			engine_name = "Jolt Physics"
		System.PhysicsEngine.OTHER:
			var engine_setting := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
			engine_name = "其他 (%s)" % engine_setting

	text = "物理引擎: %s" % engine_name
