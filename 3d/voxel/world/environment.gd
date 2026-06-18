## 体素世界环境控制器 —— 根据渲染距离动态调整雾效。
##
## 继承自 [WorldEnvironment]，根据 VoxelWorld 的有效渲染距离平滑调整雾效密度和距离。
extends WorldEnvironment

## VoxelWorld 节点引用。
@onready var voxel_world: Node = $"../VoxelWorld"

## _process 入口。每帧更新雾效参数。
##
## 参数:
##   delta: 帧时间间隔
##
## 核心逻辑：
## 1. 根据设置启用/禁用雾效
## 2. 根据有效渲染距离计算目标雾效距离
## 3. 平滑过渡到目标值
func _process(delta: float) -> void:
	environment.fog_enabled = Settings.fog_enabled

	var target_distance := clampi(voxel_world.effective_render_distance, 2, voxel_world.render_distance - 1) * Chunk.CHUNK_SIZE
	var rate := delta * 4
	Settings.fog_distance = move_toward(Settings.fog_distance, target_distance, rate)
	environment.fog_density = 0.5 / Settings.fog_distance
