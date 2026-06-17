## Set up different Split Screens
## Provide Input configuration
## Connect Split Screens to Play Area
## 设置多个分屏，提供输入配置，并将分屏连接到共享的游戏区域。
## 继承自 Node，作为整个场景树的根节点，负责统筹初始化所有分屏及其玩家。
extends Node


const KEYBOARD_OPTIONS: Dictionary[String, Dictionary] = {
	## 键盘选项字典，键为 String，值为 Dictionary。
	## 该字典内置了 4 套预设的键盘按键方案，供玩家选择。
	"wasd": {"keys": [KEY_W, KEY_A, KEY_S, KEY_D]},
	# "wasd" 方案：使用 W、A、S、D 四个按键分别控制上、左、下、右。
	"ijkl": {"keys": [KEY_I, KEY_J, KEY_K, KEY_L]},
	# "ijkl" 方案：使用 I、J、K、L 四个按键，适合第二位玩家使用。
	"arrows": {"keys": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]},
	# "arrows" 方案：使用方向键（左、右、上、下）进行控制。
	"numpad": {"keys": [KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_8]},
	# "numpad" 方案：使用小键盘的数字键 4、5、6、8 进行控制。
} # 4 keyboard sets for moving players around.

const PLAYER_COLORS: Array[Color] = [
	## 玩家颜色数组，类型为 Array[Color]。
	## 每个分屏的玩家将按索引获取一种颜色，用于视觉区分。
	Color.WHITE,
	# 索引 0：白色。
	Color("ff8f02"),
	# 索引 1：橙色（十六进制色值 ff8f02）。
	Color("05ff5a"),
	# 索引 2：绿色（十六进制色值 05ff5a）。
	Color("ff05a0")
	# 索引 3：粉色/洋红色（十六进制色值 ff05a0）。
] # Modulate Colors of each Player.


var config: Dictionary = {
	## 分屏配置字典，用于在初始化过程中临时承载参数并传递给每个 SplitScreen。
	"keyboard": KEYBOARD_OPTIONS,
	# "keyboard" 项：传入所有可用的键盘配置方案。
	"joypads": 4,
	# "joypads" 项：预设支持的手柄数量为 4 个。
	"world": null,
	# "world" 项：World2D 对象，初始为 null，将在 _ready 中填充为 play_area 的 world_2d。
	"position": Vector2(),
	# "position" 项：玩家的初始位置，初始为零向量，后续根据索引计算。
	"index": -1,
	# "index" 项：当前分屏的索引，初始为 -1，后续递增。
	"color": Color(),
	# "color" 项：当前玩家的颜色，初始为空颜色，后续从 PLAYER_COLORS 中选取。
} # Split Screen configuration Dictionary.

## 中央共享的游戏世界视口。
## @onready 表示在节点就绪后执行赋值。获取名为 "PlayArea" 的子节点（SubViewport 类型）。
## 所有 SplitScreen 的 SubViewport 都会将其 world_2d 指向 play_area.world_2d，实现同一个物理世界的多视角渲染。
@onready var play_area: SubViewport = $PlayArea


## 初始化每个分屏以及每个玩家节点。
## _ready 是 Godot 的内置虚函数，当节点及其所有子节点都进入场景树后自动调用一次。
func _ready() -> void:
	# 将 play_area 的 world_2d（2D 物理与渲染世界对象）赋值到 config 字典中。
	# 这样后续传递给 SplitScreen 时，所有分屏都会共享同一个 World2D。
	config["world"] = play_area.world_2d
	# 获取该节点（root）的所有直接子节点，返回类型为 Array[Node]。
	var children: Array[Node] = get_children()
	# 声明局部变量 index（分屏计数索引），初始值为 0，用于遍历子节点时递增。
	var index: int = 0
	# 使用 for 循环遍历每一个直接子节点。
	for child: Node in children:
		# 使用 is 运算符判断子节点的类型是否为 SplitScreen。
		# 只有 SplitScreen 类型的节点才需要进行分屏配置初始化。
		if child is SplitScreen:
			# 计算该分屏内玩家的初始位置：
			# - index % 2 得到当前索引除以 2 的余数（0 或 1），对应 x 坐标列。
			# - floor(index / 2.0) 得到当前索引除以 2 后向下取整（0 或 1），对应 y 坐标行。
			# - 将上述列和行构成 Vector2，乘以 132（格子间距/偏移量）。
			# - 最后加上 Vector2(132, 0) 进行整体向右偏移，避免玩家生成在场景原点 (0,0) 处重叠。
			# 这样 4 个玩家会按 2×2 网格排列：索引 0(1,0)、1(2,0)、2(1,1)、3(2,1) 再乘 132。
			config["position"] = Vector2(index % 2, floor(index / 2.0)) * 132 + Vector2(132, 0)
			# 将当前循环索引存入 config，用于 SplitScreen 中的 OptionButton 默认选中项。
			config["index"] = index
			# 从 PLAYER_COLORS 数组中按索引取出对应颜色，存入 config。
			config["color"] = PLAYER_COLORS[index]
			# 使用 as 运算符将 child 显式类型转换为 SplitScreen，赋值给 split_child。
			# 这样既获得了类型安全，也方便后续调用 SplitScreen 的自定义方法。
			var split_child: SplitScreen = child as SplitScreen
			# 调用 SplitScreen 的 set_config 方法，将包含位置、颜色、世界等信息的配置字典传入。
			# 这会完成该分屏的 OptionButton 初始化、玩家位置与颜色设置以及世界同步。
			split_child.set_config(config)
			# 索引自增 1，为下一个 SplitScreen 子节点准备下一个预设颜色和下拉默认项。
			index += 1
