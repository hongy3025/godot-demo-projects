## 调试信息标签 —— 显示玩家位置、渲染距离、朝向、内存和 FPS。
##
## 继承自 [Label]，按 F3 键切换显示。
extends Label

## 玩家节点引用。
@onready var player := $"../Player"
## VoxelWorld 节点引用。
@onready var voxel_world := $"../VoxelWorld"

## _process 入口。每帧更新调试信息。
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"debug"):
		visible = not visible

	text = "位置: %.1v" % player.transform.origin \
			+ "\n有效渲染距离: " + str(voxel_world.effective_render_distance) \
			+ "\n朝向: " + _cardinal_string_from_radians(player.transform.basis.get_euler().y) \
			+ "\n内存: " + "%3.0f" % (OS.get_static_memory_usage() / 1048576.0) + " MiB" \
			+ "\nFPS: %d" % Engine.get_frames_per_second()


## 将弧度角度转换为方位字符串。
##
## 参数:
##   angle: 弧度角度（-PI 到 PI），0 为北
##
## 返回: [String] 方位（北/东/南/西）
func _cardinal_string_from_radians(angle: float) -> String:
	if angle > TAU * 3 / 8:
		return "南"
	if angle < -TAU * 3 / 8:
		return "南"
	if angle > TAU * 1 / 8:
		return "西"
	if angle < -TAU * 1 / 8:
		return "东"
	return "北"
