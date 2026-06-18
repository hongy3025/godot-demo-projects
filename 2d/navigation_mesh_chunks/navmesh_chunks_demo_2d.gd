## 导航网格分块演示 —— 将导航网格分块烘焙以支持大型地图。
extends Node2D


static var map_cell_size: float = 1.0
static var chunk_size: int = 256
static var cell_size: float = 1.0
static var agent_radius: float = 10.0
static var chunk_id_to_region: Dictionary = {}


var path_start_position: Vector2


func _ready() -> void:
	NavigationServer2D.set_debug_enabled(true)

	path_start_position = %DebugPaths.global_position

	var map: RID = get_world_2d().navigation_map
	NavigationServer2D.map_set_cell_size(map, map_cell_size)

	# 禁用性能开销较大的边缘连接功能
	NavigationServer2D.map_set_use_edge_connections(map, false)

	# 解析根节点下的碰撞形状
	var source_geometry: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()
	var parse_settings: NavigationPolygon = NavigationPolygon.new()
	parse_settings.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	NavigationServer2D.parse_source_geometry_data(parse_settings, source_geometry, %ParseRootNode)

	# 添加可通行区域轮廓
	var traversable_outline: PackedVector2Array = PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(1920.0, 0.0),
			Vector2(1920.0, 1080.0),
			Vector2(0.0, 1080.0),
		])
	source_geometry.add_traversable_outline(traversable_outline)

	create_region_chunks(%ChunksContainer, source_geometry, chunk_size * cell_size, agent_radius)


## 将导航网格分块创建。
static func create_region_chunks(chunks_root_node: Node, p_source_geometry: NavigationMeshSourceGeometryData2D, p_chunk_size: float, p_agent_radius: float) -> void:
	var input_geometry_bounds: Rect2 = p_source_geometry.get_bounds()

	var start_chunk: Vector2 = floor(
			input_geometry_bounds.position / p_chunk_size
		)
	var end_chunk: Vector2 = floor(
			(input_geometry_bounds.position + input_geometry_bounds.size)
			/ p_chunk_size
		)

	for chunk_y in range(start_chunk.y, end_chunk.y + 1):
		for chunk_x in range(start_chunk.x, end_chunk.x + 1):
			var chunk_id: Vector2i = Vector2i(chunk_x, chunk_y)

			var chunk_bounding_box: Rect2 = Rect2(
					Vector2(chunk_x, chunk_y) * p_chunk_size,
					Vector2(p_chunk_size, p_chunk_size),
				)
			# 扩展边界以包含相邻块的几何体，使边缘对齐
			var baking_bounds: Rect2 = chunk_bounding_box.grow(p_chunk_size)

			var chunk_navmesh: NavigationPolygon = NavigationPolygon.new()
			chunk_navmesh.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
			chunk_navmesh.baking_rect = baking_bounds
			chunk_navmesh.border_size = p_chunk_size
			chunk_navmesh.agent_radius = p_agent_radius
			NavigationServer2D.bake_from_source_geometry_data(chunk_navmesh, p_source_geometry)

			chunk_navmesh.baking_rect = Rect2()

			# 对齐顶点以避免浮点精度问题
			var navmesh_vertices: PackedVector2Array = chunk_navmesh.vertices
			for i in navmesh_vertices.size():
				var vertex: Vector2 = navmesh_vertices[i]
				navmesh_vertices[i] = vertex.snappedf(map_cell_size * 0.1)
			chunk_navmesh.vertices = navmesh_vertices

			var chunk_region: NavigationRegion2D = NavigationRegion2D.new()
			chunk_region.navigation_polygon = chunk_navmesh
			chunks_root_node.add_child(chunk_region)

			chunk_id_to_region[chunk_id] = chunk_region


## 每帧更新路径调试显示。
func _process(_delta: float) -> void:
	var mouse_cursor_position: Vector2 = get_global_mouse_position()

	var map: RID = get_world_2d().navigation_map
	if NavigationServer2D.map_get_iteration_id(map) == 0:
		return

	var closest_point_on_navmesh: Vector2 = NavigationServer2D.map_get_closest_point(
			map,
			mouse_cursor_position
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
