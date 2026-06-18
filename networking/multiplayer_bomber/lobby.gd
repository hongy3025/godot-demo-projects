## 炸弹人大厅 UI —— 管理连接、玩家列表和游戏启动。
##
## 继承自 [Control]，作为游戏大厅界面。
## 通过 [gamestate] 单例管理网络连接和游戏状态。
extends Control


## _ready 入口：连接 gamestate 信号并设置默认玩家名称。
func _ready() -> void:
	gamestate.connection_failed.connect(_on_connection_failed)
	gamestate.connection_succeeded.connect(_on_connection_success)
	gamestate.player_list_changed.connect(refresh_lobby)
	gamestate.game_ended.connect(_on_game_ended)
	gamestate.game_error.connect(_on_game_error)
	# 根据系统环境变量 USERNAME 设置默认玩家名称，如果获取不到则使用桌面路径中的用户名作为后备。
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]


## "主机"按钮点击处理：验证名称后创建游戏服务器。
func _on_host_pressed() -> void:
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name: String = $Connect/Name.text
	gamestate.host_game(player_name)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server (%s)" % $Connect/Name.text
	refresh_lobby()


## "加入"按钮点击处理：验证名称和 IP 地址后连接到服务器。
func _on_join_pressed() -> void:
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip: String = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name: String = $Connect/Name.text
	gamestate.join_game(ip, player_name)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client (%s)" % $Connect/Name.text


## 连接成功回调：隐藏连接界面，显示玩家列表。
func _on_connection_success() -> void:
	$Connect.hide()
	$Players.show()


## 连接失败回调：恢复按钮状态并显示错误信息。
func _on_connection_failed() -> void:
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


## 游戏结束回调：显示连接界面，隐藏玩家列表。
func _on_game_ended() -> void:
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


## 游戏错误回调：弹出错误对话框。
## 参数 errtxt: 错误文本。
func _on_game_error(errtxt: String) -> void:
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


## 刷新玩家列表：从 gamestate 获取玩家列表并更新 UI。
func refresh_lobby() -> void:
	var players := gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.player_name + " (you)")
	for p: String in players:
		$Players/List.add_item(p)

	$Players/Start.disabled = not multiplayer.is_server()


## "开始游戏"按钮点击处理：调用 gamestate 开始游戏。
func _on_start_pressed() -> void:
	gamestate.begin_game()


## "查找公网 IP"链接点击处理：打开浏览器访问 icanhazip.com。
func _on_find_public_ip_pressed() -> void:
	OS.shell_open("https://icanhazip.com/")
