## 导航网格分块（Chunk）演示场景的主控制器。
##
## 继承自 [Node3D]，演示如何将大型导航网格拆分为多个小块（chunk），
## 以支持动态加载/卸载和大型开放世界的导航。
##
## 核心功能：
## 1. 从静态碰撞体解析源几何数据
## 2. 将几何数据按网格分块烘焙为多个 NavigationRegion3D
## 3. 实时显示鼠标位置的导航路径调试
extends Node3D


## 导航地图的网格单元大小。
static var map_cell_size: float = 0.25
## 每个分块的大小（以单元数计）。
static var chunk_size: int = 16
## 导航网格的体素单元大小。
static var cell_size: float = 0.25
## 导航代理半径。
static var agent_radius: float = 0.5
## 分块 ID 到 NavigationRegion3D 的映射字典。
static var chunk_id_to_region: Dictionary = {}


## 路径起点位置。
var path_start_position: Vector3


## _ready 入口。初始化导航调试、解析几何数据并创建分块区域。
func _ready() -> void:
	NavigationServer3D.set_debug_enabled(true)

	path_start_position = %DebugPaths.global_position

	var map: RID = get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(map, map_cell_size)

	# 禁用性能昂贵的边缘连接功能。
	# 此功能对合并导航网格边缘不是必需的。
	# 如果边缘对齐良好，通过边缘键即可正常合并。
	NavigationServer3D.map_set_use_edge_connections(map, false)

	# 解析解析根节点下的碰撞形状。
	var source_geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	var parse_settings: NavigationMesh = NavigationMesh.new()
	parse_settings.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	NavigationServer3D.parse_source_geometry_data(parse_settings, source_geometry, %ParseRootNode)

	create_region_chunks(%ChunksContainer, source_geometry, chunk_size * cell_size, agent_radius)


## 创建导航网格分块区域。
##
## 参数:
##   chunks_root_node: 分块区域的父节点
##   p_source_geometry: 源几何数据
##   p_chunk_size: 每个分块的世界空间大小
##   p_agent_radius: 导航代理半径
##
## 核心算法：
## 1. 计算输入几何体的 AABB 包围盒
## 2. 将包围盒光栅化为分块网格
## 3. 对每个分块，扩展烘焙边界以包含相邻分块的几何体（确保边缘对齐）
## 4. 烘焙每个分块的 NavigationMesh
## 5. 对顶点进行快照（snapped）处理以避免浮点精度问题
## 6. 创建 NavigationRegion3D 并添加到场景
static func create_region_chunks(chunks_root_node: Node, p_source_geometry: NavigationMeshSourceGeometryData3D, p_chunk_size: float, p_agent_radius: float) -> void:
	# 获取输入几何体的轴对齐包围盒，确定需要多少分块。
	var input_geometry_bounds: AABB = p_source_geometry.get_bounds()

	# 将包围盒光栅化为分块网格，确定所需的分块范围。
	var start_chunk: Vector3 = floor(
			input_geometry_bounds.position / p_chunk_size
		)
	var end_chunk: Vector3 = floor(
			(input_geometry_bounds.position + input_geometry_bounds.size)
			/ p_chunk_size
		)

	# NavigationMesh.border_size 仅限于 xz 轴。
	# 因此 y 轴只能烘焙一个分块，且烘焙边界需要跨越整个 y 轴范围。
	# 否则会创建重复的多边形并堆叠在一起，导致合并错误。
	var bounds_min_height: float = start_chunk.y
	var bounds_max_height: float = end_chunk.y + p_chunk_size
	var chunk_y: int = 0

	for chunk_z in range(start_chunk.z, end_chunk.z + 1):
		for chunk_x in range(start_chunk.x, end_chunk.x + 1):
			var chunk_id: Vector3i = Vector3i(chunk_x, chunk_y, chunk_z)

			var chunk_bounding_box: AABB = AABB(
					Vector3(chunk_x, bounds_min_height, chunk_z) * p_chunk_size,
					Vector3(p_chunk_size, bounds_max_height, p_chunk_size),
				)
			# 扩展分块包围盒以包含相邻分块的几何体，确保边缘对齐。
			# border_size 与扩展量相同，使最终导航网格达到预期的分块大小。
			var baking_bounds: AABB = chunk_bounding_box.grow(p_chunk_size)

			var chunk_navmesh: NavigationMesh = NavigationMesh.new()
			chunk_navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
			chunk_navmesh.cell_size = cell_size
			chunk_navmesh.cell_height = cell_size
			chunk_navmesh.filter_baking_aabb = baking_bounds
			chunk_navmesh.border_size = p_chunk_size
			chunk_navmesh.agent_radius = p_agent_radius
			NavigationServer3D.bake_from_source_geometry_data(chunk_navmesh, p_source_geometry)

			# 重置烘焙边界以避免渲染其调试可视化。
			chunk_navmesh.filter_baking_aabb = AABB()

			# 对顶点位置进行快照处理，避免浮点精度导致的栅格化问题。
			var navmesh_vertices: PackedVector3Array = chunk_navmesh.vertices
			for i in navmesh_vertices.size():
				var vertex: Vector3 = navmesh_vertices[i]
				navmesh_vertices[i] = vertex.snappedf(map_cell_size * 0.1)
			chunk_navmesh.vertices = navmesh_vertices

			var chunk_region: NavigationRegion3D = NavigationRegion3D.new()
			chunk_region.navigation_mesh = chunk_navmesh
			chunks_root_node.add_child(chunk_region)

			chunk_id_to_region[chunk_id] = chunk_region


## _process 入口。每帧更新鼠标位置的导航路径调试显示。
##
## 参数:
##   delta: 帧时间间隔（未使用）
##
## 核心逻辑：
## 1. 从摄像机向鼠标位置发射射线
## 2. 获取导航网格上的最近点
## 3. 左键点击设置路径起点
## 4. 更新多个路径调试节点的目标位置
func _process(_delta: float) -> void:
	var mouse_cursor_position: Vector2 = get_viewport().get_mouse_position()

	var map: RID = get_world_3d().navigation_map
	# 地图未同步时（为空）不查询。
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	var camera_ray_length: float = 1000.0
	var camera_ray_start: Vector3 = camera.project_ray_origin(mouse_cursor_position)
	var camera_ray_end: Vector3 = camera_ray_start + camera.project_ray_normal(mouse_cursor_position) * camera_ray_length
	var closest_point_on_navmesh: Vector3 = NavigationServer3D.map_get_closest_point_to_segment(
			map,
			camera_ray_start,
			camera_ray_end
		)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		path_start_position = closest_point_on_navmesh

	%DebugPaths.global_position = path_start_position

	%PathDebugCorridorFunnel.target_position = closest_point_on_navmesh
	%PathDebugEdgeCentered.target_position = closest_point_on_navmesh
	%PathDebugNoPostProcessing.target_position = closest_point_on_navmesh

	%PathDebugCorridorFunnel.get_next_path_position()
	%PathDebugEdgeCentered.get_next_path_position()
	%PathDebugNoPostProcessing.get_next_path_position()
