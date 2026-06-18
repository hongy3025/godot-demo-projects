## Y 轴深度排序节点 —— 按 3D 空间的 Y 坐标对兄弟节点进行排序。
##
## 继承自 [Node]（而非 Node2D 或 Node25D），作为父节点的子节点存在。
## 在 _process 中自动对其父节点的所有 [Node2D] 子节点按 Y 轴深度排序，
## 通过设置 z_index 实现正确的远近遮挡关系。
##
## 与 C# 版本的区别: GDScript 的执行顺序不同，因此排序逻辑在 _process 中直接执行，
## 而非延迟一帧。
@tool
@icon("res://addons/node25d/icons/y_sort_25d_icon.png")
class_name YSort25D
extends Node  # 注意: 不继承 Node2D 或 Node25D，避免影响排序


## 是否在 _process 中自动调用 sort()。设为 false 可手动控制排序时机。
@export var sort_enabled: bool = true
# 缓存父节点引用（必须是 Node2D，但不要求是 Node25D）
var _parent_node: Node2D


## _ready 入口，获取父节点引用并缓存。
func _ready():
	_parent_node = get_parent()


## _process 入口，每帧检测是否需要执行排序。
func _process(_delta):
	if sort_enabled:
		sort()


## 执行深度排序。遍历父节点的所有子节点，筛选出 Node2D 类型，
## 按 Y 坐标（带轻微 XZ 修正）排序，并设置 z_index。
##
## 限制: 最多支持 4000 个节点（z_index 范围 -4096 到 4096，步长 2）。
func sort():
	if _parent_node == null:
		return  # _ready() 尚未执行
	var parent_children = _parent_node.get_children()
	if parent_children.size() > 4000:
		# z_index 范围为 -4096 ~ 4096，且需要为阴影层留出中间间隔
		printerr("Sorting failed: Max number of YSort25D nodes is 4000.")
		return

	# 筛选出所有 Node2D 类型的子节点
	var node25d_nodes = []
	for n in parent_children:
		if n.get_class() == "Node2D":
			node25d_nodes.append(n)
	# 使用 Node25D 的静态排序方法，按 Y 坐标 + 轻微 XZ 修正排序
	node25d_nodes.sort_custom(Callable(Node25D, &"y_sort_slight_xz"))

	# 从 -4000 开始分配 z_index，每次 +2，为阴影层留出中间位置
	var z_index = -4000
	for i in range(0, node25d_nodes.size()):
		node25d_nodes[i].z_index = z_index
		z_index += 2
