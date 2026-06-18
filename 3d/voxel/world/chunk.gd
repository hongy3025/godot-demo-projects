## 体素区块 —— 包含方块数据、网格和碰撞体的基本单元。
##
## 继承自 [StaticBody3D]，由 VoxelWorld 实例化并赋予数据。
## 使用 WorkerThreadPool 在子线程中生成网格。
## 支持相邻区块的透明面剔除和不同纹理（顶面/底面不同）。
class_name Chunk
extends StaticBody3D

## 区块大小（16x16x16），需与 TerrainGenerator 保持一致。
const CHUNK_SIZE := 16
## 纹理图集宽度（8 列）。
const TEXTURE_SHEET_WIDTH := 8
## 区块最大索引。
const CHUNK_LAST_INDEX := CHUNK_SIZE - 1
## 单个纹理图块大小。
const TEXTURE_TILE_SIZE := 1.0 / TEXTURE_SHEET_WIDTH
## 碰撞体半边长。
const CHUNK_EXTENTS := Vector3.ONE / 2.0
## 六个方向的偏移向量。
const DIRECTIONS: Array[Vector3i] = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.DOWN, Vector3i.UP, Vector3i.FORWARD, Vector3i.BACK]

## 方块数据字典（子位置 -> 方块 ID）。
var data: Dictionary[Vector3i, int] = {}
## 区块位置。
var chunk_position := Vector3i()
## 初始网格是否已生成。
var is_initial_mesh_generated: bool = false
## 网格生成任务 ID（用于 WorkerThreadPool）。
var mesh_task_id := 0

## 共享的 BoxShape3D 实例（所有区块共用）。
static var box_shape: BoxShape3D = null

## VoxelWorld 父节点引用。
@onready var voxel_world := get_parent() as VoxelWorld


## _init 构造函数。初始化区块数据、位置和碰撞体。
##
## 参数:
##   pos: 区块位置
func _init(pos: Vector3i) -> void:
	chunk_position = pos
	transform.origin = Vector3(chunk_position * CHUNK_SIZE)
	name = str(chunk_position)
	if Settings.world_type == 0:
		data = TerrainGenerator.random_blocks()
	else:
		data = TerrainGenerator.flat(chunk_position)

	# 由于物理引擎限制，只能在主线程添加碰撞体。
	_generate_chunk_collider()


## _notification 入口。在删除前等待网格生成任务完成。
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if mesh_task_id >= 1:
			WorkerThreadPool.wait_for_task_completion(mesh_task_id)
			mesh_task_id = 0


## 尝试生成初始网格。仅在所有相邻区块都已创建时生成。
##
## 参数:
##   all_chunks: 所有已加载区块的字典
##
## 使用 WorkerThreadPool 在子线程中生成网格。
func try_initial_generate_mesh(all_chunks: Dictionary[Vector3i, Chunk]) -> void:
	for dir in DIRECTIONS:
		if not all_chunks.has(chunk_position + dir):
			return
	is_initial_mesh_generated = true
	mesh_task_id = WorkerThreadPool.add_task(_generate_chunk_mesh, true)


## 重新生成区块（数据变化后调用）。
##
## 临时从场景树移除以避免 Jolt Physics 下更新复杂碰撞体的性能开销。
func regenerate() -> void:
	voxel_world.remove_child(self)

	# 清除旧节点。
	for c in get_children():
		remove_child(c)
		c.queue_free()

	# 生成新节点。
	_generate_chunk_collider()
	_generate_chunk_mesh()

	voxel_world.add_child(self)


## 生成区块碰撞体。为每个非特殊方块创建碰撞体。
func _generate_chunk_collider() -> void:
	if data.is_empty():
		return

	for block_position: Vector3i in data.keys():
		var block_id: int = data[block_position]
		if block_id != 27 and block_id != 28:
			_create_block_collider(block_position)


## 生成区块网格。使用 SurfaceTool 构建合并网格。
func _generate_chunk_mesh() -> void:
	if data.is_empty():
		return

	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for block_position: Vector3i in data.keys():
		var block_id: int = data[block_position]
		_draw_block_mesh(surface_tool, block_position, block_id)

	surface_tool.generate_tangents()
	surface_tool.index()
	var array_mesh := surface_tool.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = array_mesh
	mi.material_override = preload("res://world/textures/material.tres")
	add_child.call_deferred(mi)


## 绘制单个方块的网格（带相邻面剔除）。
##
## 参数:
##   surface_tool: SurfaceTool 实例
##   block_sub_position: 方块在区块内的子位置
##   block_id: 方块 ID
##
## 核心算法：
## 1. 灌木类方块（ID 27/28）使用交叉面绘制
## 2. 普通方块检查六个方向的相邻方块，仅绘制暴露的面
## 3. 支持不同顶面/底面纹理（草地、熔炉、原木、书架）
func _draw_block_mesh(surface_tool: SurfaceTool, block_sub_position: Vector3i, block_id: int) -> void:
	var verts := Chunk.calculate_block_verts(block_sub_position)
	var uvs := Chunk.calculate_block_uvs(block_id)
	var top_uvs := uvs
	var bottom_uvs := uvs

	# 灌木类方块特殊绘制。
	if block_id == 27 or block_id == 28:
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[7], verts[5]], uvs, Vector3(-1, 0, 1).normalized())
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[2], verts[0]], uvs, Vector3(1, 0, -1).normalized())
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[6], verts[4]], uvs, Vector3(1, 0, 1).normalized())
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[3], verts[1]], uvs, Vector3(-1, 0, -1).normalized())
		return

	# 不同方块的不同顶面/底面纹理。
	if block_id == 3: # 草地。
		top_uvs = Chunk.calculate_block_uvs(0)
		bottom_uvs = Chunk.calculate_block_uvs(2)
	elif block_id == 5: # 熔炉。
		top_uvs = Chunk.calculate_block_uvs(31)
		bottom_uvs = top_uvs
	elif block_id == 12: # 原木。
		top_uvs = Chunk.calculate_block_uvs(30)
		bottom_uvs = top_uvs
	elif block_id == 19: # 书架。
		top_uvs = Chunk.calculate_block_uvs(4)
		bottom_uvs = top_uvs

	# 六个面的绘制（带相邻面剔除）。
	var other_block_id := 0
	# 左面（-X）。
	if block_sub_position.x == 0:
		var other_sub_pos: Vector3i = Vector3i(15, block_sub_position.y, block_sub_position.z)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.LEFT, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.LEFT
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], uvs, Vector3.LEFT)

	# 右面（+X）。
	other_block_id = 0
	if block_sub_position.x == CHUNK_SIZE - 1:
		var other_sub_pos: Vector3i = Vector3i(0, block_sub_position.y, block_sub_position.z)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.RIGHT, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.RIGHT
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], uvs, Vector3.RIGHT)

	# 前面（-Z）。
	other_block_id = 0
	if block_sub_position.z == 0:
		var other_sub_pos: Vector3i = Vector3i(block_sub_position.x, block_sub_position.y, CHUNK_SIZE - 1)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.FORWARD, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.FORWARD
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], uvs, Vector3.FORWARD)

	# 后面（+Z）。
	other_block_id = 0
	if block_sub_position.z == CHUNK_SIZE - 1:
		var other_sub_pos: Vector3i = Vector3i(block_sub_position.x, block_sub_position.y, 0)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.BACK, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.BACK
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], uvs, Vector3.BACK)

	# 下面（-Y）。
	other_block_id = 0
	if block_sub_position.y == 0:
		var other_sub_pos: Vector3i = Vector3i(block_sub_position.x, CHUNK_SIZE - 1, block_sub_position.z)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.DOWN, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.DOWN
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[4], verts[5], verts[0], verts[1]], bottom_uvs, Vector3.DOWN)

	# 上面（+Y）。
	other_block_id = 0
	if block_sub_position.y == CHUNK_SIZE - 1:
		var other_sub_pos: Vector3i = Vector3i(block_sub_position.x, 0, block_sub_position.z)
		other_block_id = voxel_world.get_block_in_chunk(chunk_position + Vector3i.UP, other_sub_pos)
	else:
		var other_block_sub_pos: Vector3i = block_sub_position + Vector3i.UP
		if data.has(other_block_sub_pos):
			other_block_id = data[other_block_sub_pos]
	if block_id != other_block_id and Chunk.is_block_transparent(other_block_id):
		_draw_block_face(surface_tool, [verts[2], verts[3], verts[6], verts[7]], top_uvs, Vector3.UP)


## 绘制单个方块面（两个三角形）。
##
## 参数:
##   surface_tool: SurfaceTool 实例
##   verts: 四个顶点
##   uvs: 四个 UV 坐标
##   normal: 面法线
func _draw_block_face(surface_tool: SurfaceTool, verts: Array[Vector3], uvs: Array[Vector2], normal: Vector3) -> void:
	surface_tool.set_normal(normal)
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[3]); surface_tool.add_vertex(verts[3])

	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(verts[0])


## 创建单个方块的碰撞体。
##
## 参数:
##   block_sub_position: 方块子位置
func _create_block_collider(block_sub_position: Vector3) -> void:
	if not box_shape:
		box_shape = BoxShape3D.new()
		box_shape.extents = CHUNK_EXTENTS

	var collider := CollisionShape3D.new()
	collider.shape = box_shape
	collider.transform.origin = block_sub_position + CHUNK_EXTENTS
	add_child(collider)


## 计算方块 ID 对应的 UV 坐标。
##
## 参数:
##   block_id: 方块 ID
##
## 返回: [Array[Vector2]] 四个 UV 坐标
static func calculate_block_uvs(block_id: int) -> Array[Vector2]:
	@warning_ignore("integer_division")
	var row := block_id / TEXTURE_SHEET_WIDTH
	var col := block_id % TEXTURE_SHEET_WIDTH

	return [
			# Godot 4 在纹理边缘存在接缝 bug，添加 0.01 边距修复。
			TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.01),
			TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.99),
			TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.01),
			TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.99),
		]


## 计算方块子位置对应的 8 个顶点。
##
## 参数:
##   block_position: 方块子位置
##
## 返回: [Array[Vector3]] 8 个顶点坐标
static func calculate_block_verts(block_position: Vector3) -> Array[Vector3]:
	return [
			Vector3(block_position.x, block_position.y, block_position.z),
			Vector3(block_position.x, block_position.y, block_position.z + 1),
			Vector3(block_position.x, block_position.y + 1, block_position.z),
			Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
			Vector3(block_position.x + 1, block_position.y, block_position.z),
			Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
			Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
			Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
		]


## 判断方块 ID 是否为透明方块。
##
## 参数:
##   block_id: 方块 ID
##
## 返回: [int] 1 表示透明，0 表示不透明
static func is_block_transparent(block_id: int) -> int:
	return block_id == 0 or (block_id > 25 and block_id < 30)
