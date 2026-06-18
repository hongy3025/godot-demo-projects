## 炸弹人游戏计分板 —— 管理玩家分数显示和胜负判定。
##
## 继承自 [HBoxContainer]，作为游戏顶部的计分板 UI。
## 每帧检测岩石是否全部被摧毁，如果是则宣布获胜者。
extends HBoxContainer

## 存储每个玩家的计分数据，格式为 { id: { name, label, score } }。
var player_labels := {}


## _process 每帧处理：检测岩石数量，如果为 0 则宣布获胜者。
func _process(_delta: float) -> void:
	var rocks_left := $"../Rocks".get_child_count()
	if rocks_left == 0:
		var winner_name: String = ""
		var winner_score := 0
		for p: int in player_labels:
			if player_labels[p].score > winner_score:
				winner_score = player_labels[p].score
				winner_name = player_labels[p].name

		$"../Winner".set_text("THE WINNER IS:\n" + winner_name)
		$"../Winner".show()


## 增加指定玩家的分数。
## 参数 for_who: 玩家 ID。
func increase_score(for_who: int) -> void:
	assert(for_who in player_labels)

	var pl: Dictionary = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.name + "\n" + str(pl.score))


## 添加新玩家到计分板。
## 参数 id: 玩家 ID；new_player_name: 玩家名称。
func add_player(id: int, new_player_name: String) -> void:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = new_player_name + "\n" + "0"
	label.modulate = gamestate.get_player_color(new_player_name)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.add_theme_font_override(&"font", preload("res://montserrat.otf"))
	label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	label.add_theme_constant_override(&"outline_size", 9)
	label.add_theme_font_size_override(&"font_size", 18)
	add_child(label)

	player_labels[id] = {
		name = new_player_name,
		label = label,
		score = 0,
	}


## _ready 入口：隐藏获胜者标签。
func _ready() -> void:
	$"../Winner".hide()


## "退出游戏"按钮点击处理：调用 gamestate 结束游戏。
func _on_exit_game_pressed() -> void:
	gamestate.end_game()
