## 乒乓球游戏主逻辑 —— 管理计分、胜负判定和游戏流程。
##
## 继承自 [Node2D]，作为乒乓球游戏场景的根节点。
## 使用 @rpc 注解实现网络同步，服务器作为权威端验证得分。
extends Node2D

## 游戏结束信号，由退出按钮触发。
signal game_finished()

## 获胜所需分数。
const SCORE_TO_WIN = 10

## 左侧玩家得分。
var score_left := 0
## 右侧玩家得分。
var score_right := 0

## 右侧玩家（Player2）节点引用。
@onready var player2: Area2D = $Player2
## 左侧得分显示标签。
@onready var score_left_node: Label = $ScoreLeft
## 右侧得分显示标签。
@onready var score_right_node: Label = $ScoreRight
## 左侧获胜提示标签。
@onready var winner_left: Label = $WinnerLeft
## 右侧获胜提示标签。
@onready var winner_right: Label = $WinnerRight


## _ready 入口：设置玩家 2 的网络权限。
##
## 服务器端：将玩家 2 的控制权交给另一个对等端。
## 客户端：将玩家 2 的控制权交给自己。
func _ready() -> void:
	# 默认情况下，服务器端所有节点继承自 master，客户端所有节点继承自 puppet。
	# set_multiplayer_authority 默认是树递归的。
	if multiplayer.is_server():
		player2.set_multiplayer_authority(multiplayer.get_peers()[0])
	else:
		player2.set_multiplayer_authority(multiplayer.get_unique_id())

	print("Unique id: ", multiplayer.get_unique_id())


## 更新得分。任何对等端可调用，在所有对等端本地执行。
##
## 参数 add_to_left: true 表示左侧得分，false 表示右侧得分。
## 当某方分数达到 SCORE_TO_WIN 时，显示获胜者并停止球运动。
@rpc("any_peer", "call_local")
func update_score(add_to_left: int) -> void:
	if add_to_left:
		score_left += 1
		score_left_node.set_text(str(score_left))
	else:
		score_right += 1
		score_right_node.set_text(str(score_right))

	var game_ended: bool = false
	if score_left == SCORE_TO_WIN:
		winner_left.show()
		game_ended = true
	elif score_right == SCORE_TO_WIN:
		winner_right.show()
		game_ended = true

	if game_ended:
		$ExitGame.show()
		$Ball.stop.rpc()


## "退出游戏"按钮点击处理：发射 game_finished 信号。
func _on_exit_game_pressed() -> void:
	game_finished.emit()
