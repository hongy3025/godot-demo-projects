## 关卡控制器 —— 随机生成刚体立方体。
##
## 继承自 [Node3D]，定时在关卡上方随机位置生成 RigidBody3D 立方体。
extends Node3D

## 定时器超时回调。在关卡上方随机位置生成刚体立方体。
func _on_SpawnTimer_timeout() -> void:
	var new_rb: RigidBody3D = preload("res://cube_rigidbody.tscn").instantiate()
	new_rb.position.y = 15
	new_rb.position.x = randf_range(-5, 5)
	new_rb.position.z = randf_range(-5, 5)
	add_child(new_rb)
