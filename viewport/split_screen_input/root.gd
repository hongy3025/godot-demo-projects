## 分屏输入根节点 —— 设置多个分屏、提供输入配置、将分屏连接到共享游戏区域。
##
## 继承自 [Node]，作为场景的根控制器。
## 管理 4 套键盘按键方案和最多 4 个手柄，为每个 SplitScreen 子节点分配配置。
extends Node

## 4 套键盘按键方案，用于控制不同玩家的移动。
## wasd: W/A/S/D 键
## ijkl: I/J/K/L 键
## arrows: 方向键
## numpad: 小键盘 4/5/6/8 键
const KEYBOARD_OPTIONS: Dictionary[String, Dictionary] = {
	"wasd": {"keys": [KEY_W, KEY_A, KEY_S, KEY_D]},
	"ijkl": {"keys": [KEY_I, KEY_J, KEY_K, KEY_L]},
	"arrows": {"keys": [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]},
	"numpad": {"keys": [KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_8]},
}

## 每个玩家的颜色调制值，用于区分不同玩家。
const PLAYER_COLORS: Array[Color] = [
	Color.WHITE,
	Color("ff8f02"),
	Color("05ff5a"),
	Color("ff05a0")
]

## 分屏配置字典模板，包含键盘选项、手柄数量、World2D、位置、索引和颜色。
var config: Dictionary = {
	"keyboard": KEYBOARD_OPTIONS,
	"joypads": 4,
	"world": null,
	"position": Vector2(),
	"index": -1,
	"color": Color(),
}

## 所有分屏共享的游戏区域子视口。
@onready var play_area: SubViewport = $PlayArea


## 初始化：遍历所有子节点，为每个 SplitScreen 分配配置。
## 计算每个分屏的位置（2x2 网格布局），分配颜色和索引。
func _ready() -> void:
	config["world"] = play_area.world_2d
	var children: Array[Node] = get_children()
	var index: int = 0
	for child: Node in children:
		if child is SplitScreen:
			# 计算分屏位置：2 列布局，每个分屏 132 像素宽，偏移 132 像素
			config["position"] = Vector2(index % 2, floor(index / 2.0)) * 132 + Vector2(132, 0)
			config["index"] = index
			config["color"] = PLAYER_COLORS[index]
			var split_child: SplitScreen = child as SplitScreen
			split_child.set_config(config)
			index += 1
