## 体素世界管理器 —— 管理 Chunk 的创建和删除。
##
## 继承自 [Node]，根据玩家位置动态加载/卸载区块，
## 每帧最多生成一个区块的数据/碰撞体（网格生成在子线程中）。
class_name VoxelWorld
extends Node

## 区块中心点偏移。
const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * Chunk.CHUNK_SIZE
## 区块末尾索引。
const CHUNK_END_SIZE = Chunk.CHUNK_SIZE - 1
## 六个方向的偏移向量。
const DIRECTIONS: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.DOWN, Vector3i.UP, Vector3i.FORWARD, Vector3i.BACK]

## 渲染距离（区块数）。
var render_distance: int:
	set(value):
		render_distance = value
		_delete_distance = value + 2

## 删除距离（渲染距离 + 2）。
var _delete_distance := 0
## 当前生效的渲染距离（逐步增加以实现渐进加载）。
var effective_render_distance := 0
## 上一帧玩家所在的区块位置。
var _old_player_chunk := Vector3i()

## 是否正在生成区块。
var _generating: bool = true
## 是否正在删除区块。
var _deleting: bool = false

## 所有已加载的区块字典（位置 -> Chunk）。
var _chunks: Dictionary[Vector3i, Chunk] = {}

## 玩家节点引用。
@onready var player: CharacterBody3D = $"../Player"

## _process 入口。每帧检查并生成/删除区块。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 检查玩家是否移动到新区块，触发删除和生成
## 2. 在渲染距离内逐步生成区块（每帧一个）
## 3. 渐进增加 effective_render_distance 直到达到目标值
func _process(_delta: float) -> void:
	render_distance = Settings.render_distance
	var player_chunk := Vector3i((player.transform.origin / Chunk.CHUNK_SIZE).round())

	if _deleting or player_chunk != _old_player_chunk:
		_delete_far_away_chunks(player_chunk)
		_generating = true

	if not _generating:
		return

	# 根据玩家移动方向预生成区块。
	@warning_ignore("integer_division")
	player_chunk.y += roundi(clampf(player.velocity.y, -render_distance / 4, render_distance / 4))

	# 检查范围内的区块，不存在则创建。
	for x in range(player_chunk.x - effective_render_distance, player_chunk.x + effective_render_distance):
		for y in range(player_chunk.y - effective_render_distance, player_chunk.y + effective_render_distance):
			for z in range(player_chunk.z - effective_render_distance, player_chunk.z + effective_render_distance):
				var chunk_position := Vector3i(x, y, z)
				if Vector3(player_chunk).distance_to(Vector3(chunk_position)) > render_distance:
					continue

				if _chunks.has(chunk_position):
					continue

				var chunk := Chunk.new(chunk_position)
				_chunks[chunk_position] = chunk
				add_child(chunk)
				chunk.try_initial_generate_mesh(_chunks)
				for dir in DIRECTIONS:
					var neighbor: Chunk = _chunks.get(chunk_position + dir)
					if neighbor != null and not neighbor.is_initial_mesh_generated:
						neighbor.try_initial_generate_mesh(_chunks)
				# 每帧最多生成一个区块的数据/碰撞体。
				# 网格生成在子线程中，因此上述可能同时生成多个网格。
				return

	# 如果没有生成任何区块，增加有效渲染距离。
	if effective_render_distance < render_distance:
		effective_render_distance += 1
	else:
		_generating = false


## 获取指定区块和子位置上的方块 ID。
##
## 参数:
##   chunk_position: 区块位置
##   block_sub_position: 方块在区块内的子位置
##
## 返回: [int] 方块 ID，0 表示空
func get_block_in_chunk(chunk_position: Vector3i, block_sub_position: Vector3i) -> int:
	if _chunks.has(chunk_position):
		var chunk: Chunk = _chunks[chunk_position]
		if chunk.data.has(block_sub_position):
			return chunk.data[block_sub_position]
	return 0


## 在世界坐标位置设置方块。
##
## 参数:
##   block_global_position: 方块的世界坐标
##   block_id: 方块 ID（0 表示删除）
##
## 如果删除的是透明方块或位于区块边缘，还需要重新生成相邻区块。
func set_block_global_position(block_global_position: Vector3i, block_id: int) -> void:
	var chunk_position := Vector3i((Vector3(block_global_position) / Chunk.CHUNK_SIZE).floor())
	var chunk: Chunk = _chunks[chunk_position]
	var sub_position := Vector3i(Vector3(block_global_position).posmod(Chunk.CHUNK_SIZE))
	if block_id == 0:
		chunk.data.erase(sub_position)
	else:
		chunk.data[sub_position] = block_id
	chunk.regenerate()

	# 如果操作的是透明方块或位于区块边缘，需要重新生成相邻区块。
	if Chunk.is_block_transparent(block_id):
		if sub_position.x == 0:
			_chunks[chunk_position + Vector3i.LEFT].regenerate()
		elif sub_position.x == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.RIGHT].regenerate()
		if sub_position.z == 0:
			_chunks[chunk_position + Vector3i.FORWARD].regenerate()
		elif sub_position.z == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.BACK].regenerate()
		if sub_position.y == 0:
			_chunks[chunk_position + Vector3i.DOWN].regenerate()
		elif sub_position.y == CHUNK_END_SIZE:
			_chunks[chunk_position + Vector3i.UP].regenerate()


## 清理所有区块并停止处理。
func clean_up() -> void:
	_chunks = {}
	set_process(false)

	for c in get_children():
		c.free()


## 删除远离玩家的区块。
##
## 参数:
##   player_chunk: 玩家当前区块位置
##
## 每帧最多删除 2~8 个区块以避免卡顿。
func _delete_far_away_chunks(player_chunk: Vector3i) -> void:
	_old_player_chunk = player_chunk
	effective_render_distance = maxi(1, effective_render_distance - 1)

	var deleted_this_frame := 0
	# 移动越快，删除越激进。
	var max_deletions := clampi(2 * (render_distance - effective_render_distance), 2, 8)
	for chunk_position_key: Vector3i in _chunks.keys():
		if Vector3(player_chunk).distance_to(Vector3(chunk_position_key)) > _delete_distance:
			_chunks[chunk_position_key].queue_free()
			_chunks.erase(chunk_position_key)
			deleted_this_frame += 1
			if deleted_this_frame > max_deletions:
				_deleting = true
				return

	_deleting = false
