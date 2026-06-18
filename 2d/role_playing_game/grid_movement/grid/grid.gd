## 网格系统 —— 管理 TileMap 上的格子状态和棋子移动。
## 继承自 TileMapLayer，负责处理移动请求、碰撞检测和对话触发。
class_name Grid
extends TileMapLayer

## 格子类型枚举（与 Pawn.CellType 对应）。
enum CellType {
	ACTOR,    # 角色
	OBSTACLE, # 障碍物
	OBJECT,   # 物体
}

## 对话 UI 节点引用，用于触发对话。
@export var dialogue_ui: Node

## 初始化：将所有子节点（棋子）注册到对应的格子位置上。
func _ready() -> void:
	for child in get_children():
		set_cell(local_to_map(child.position), child.type, Vector2i.ZERO)


## 获取指定格子上指定类型的棋子节点。
## 参数 cell: 格子坐标。
## 参数 type: 要查找的格子类型。
## 返回: 找到的 Node2D 节点，未找到则返回 null。
func get_cell_pawn(cell: Vector2i, type: CellType = CellType.ACTOR) -> Node2D:
	for node in get_children():
		if node.type != type:
			continue
		if local_to_map(node.position) == cell:
			return node

	return null


## 处理棋子的移动请求。
## 检查目标格子是否可通行，并更新格子状态。
## 参数 pawn: 发起移动的棋子。
## 参数 direction: 移动方向向量。
## 返回: 目标位置的全局坐标（可通行时），或 Vector2i.ZERO（不可通行时）。
func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell_start := local_to_map(pawn.position)
	var cell_target := cell_start + direction

	var cell_tile_id := get_cell_source_id(cell_target)
	match cell_tile_id:
		-1:  # 空位，可通行
			set_cell(cell_target, CellType.ACTOR, Vector2i.ZERO)
			set_cell(cell_start, -1, Vector2i.ZERO)
			return map_to_local(cell_target)

		CellType.OBJECT, CellType.ACTOR:  # 有物体或角色，尝试触发对话
			var target_pawn := get_cell_pawn(cell_target, cell_tile_id)

			if not target_pawn.has_node(^"DialoguePlayer"):
				return Vector2i.ZERO

			dialogue_ui.show_dialogue(pawn, target_pawn.get_node(^"DialoguePlayer"))

	return Vector2i.ZERO
